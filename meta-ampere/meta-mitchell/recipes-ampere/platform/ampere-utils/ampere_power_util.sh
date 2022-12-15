#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-common/recipes-ampere/platform/ampere-utils/ampere_power_control_lock.sh
source /usr/sbin/ampere_power_control_lock.sh

# Usage of this utility
function usage() {
	echo "usage: power-util mb [status|shutdown_ack|force_reset|soft_off|host_reboot_wa]";
}

power_status() {
	st=$(busctl get-property xyz.openbmc_project.State.Chassis /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis CurrentPowerState | cut -d"." -f6)
	if [ "$st" == "On\"" ]; then
		echo "on"
	else
		echo "off"
	fi
}

shutdown_ack() {
	if [ -f "/run/openbmc/host@0-softpoweroff" ]; then
		echo "Receive shutdown ACK triggered after softportoff the host."
		touch /run/openbmc/host@0-softpoweroff-shutdown-ack
	else
		echo "Receive shutdown ACK triggered"
		sleep 3
		systemctl start obmc-chassis-poweroff@0.target
	fi
}

soft_off() {
	# Trigger shutdown_req
	touch /run/openbmc/host@0-softpoweroff
	gpioset $(gpiofind host0-shd-req-n)=0
	sleep 0.05
	gpioset $(gpiofind host0-shd-req-n)=1

	# Wait for shutdown_ack from the host in 30 seconds
	cnt=30
	while [ $cnt -gt 0 ];
	do
		# Wait for SHUTDOWN_ACK and create the host@0-softpoweroff-shutdown-ack
		if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
			break
		fi
		sleep 1
		cnt=$((cnt - 1))
	done

	# Softpoweroff is successed
	sleep 2
	rm -rf /run/openbmc/host@0-softpoweroff
	if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
		rm -rf /run/openbmc/host@0-softpoweroff-shutdown-ack
	fi
	echo 0
}

force_reset() {
	if [ -f "/run/openbmc/host@0-softpoweroff" ]; then
		# In graceful host reset, after trigger os shutdown,
		# the phosphor-state-manager will call force-warm-reset
		# in this case the force_reset should wait for shutdown_ack from host
		cnt=30
		while [ $cnt -gt 0 ];
		do
			if [ -f "/run/openbmc/host@0-softpoweroff-shutdown-ack" ]; then
				break
			fi
			echo "Waiting for shutdown-ack count down $cnt"
			sleep 1
			cnt=$((cnt - 1))
		done
		# The host OS is failed to shutdown
		if [ $cnt == 0 ]; then
			echo "Shutdown-ack time out after 30s."
			exit 0
		fi
	fi
	rm -f /run/openbmc/host@0-on
	echo "Triggering sysreset pin"
	gpioset $(gpiofind host0-sysreset-n)=0
	sleep 1
	gpioset $(gpiofind host0-sysreset-n)=1
}

wait_bert_complete() {
	# Wait maximum 60 seconds for BERT completed
	cnt=20
	while [ $cnt -gt 0 ]
	do
		bert_done=$(busctl get-property com.ampere.CrashCapture.Trigger /com/ampere/crashcapture/trigger com.ampere.CrashCapture.Trigger TriggerActions | cut -d"." -f6)
		if ! [ "$bert_done" == "Done\"" ]; then
			sleep 3
			cnt=$((cnt - 1))
		else
			break
		fi
	done
	if [ "$cnt" -eq "0" ]; then
		echo "Timeout 60 seconds, BERT is still not completed"
		return 1
	fi
	return 0
}

host_reboot_wa() {
    echo "Notify Crash Capture reboot action from host."
    busctl set-property com.ampere.CrashCapture.Trigger \
       /com/ampere/crashcapture/trigger \
       com.ampere.CrashCapture.Trigger \
       TriggerProcess b true
    bert_timeout="0"
    # Wait until RAS BERT process completed
    wait_bert_complete
    bert_timeout=$?
    # If the crash capture process is crash or works unstable, it does
    # not unmask the power action. We should call unmask here to make sure
    # the power control is unmasked
    if [[ "${bert_timeout}" == "1" ]]; then
        unmask_reboot_targets
        unmask_off_targets
    fi
    
    busctl set-property xyz.openbmc_project.State.Chassis \
        /xyz/openbmc_project/state/chassis0 xyz.openbmc_project.State.Chassis \
        RequestedPowerTransition s "xyz.openbmc_project.State.Chassis.Transition.Off"

    while ( true )
    do
        if systemctl status obmc-power-off@0.target | grep "Active: active"; then
            break;
        fi
        sleep 2
    done
    echo "The power is already Off."

    # Keep the system off if BERT is timeout
    if [[ "${bert_timeout}" == "0" ]]; then
        busctl set-property xyz.openbmc_project.State.Host \
            /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
            RequestedHostTransition s "xyz.openbmc_project.State.Host.Transition.On"
    fi
}

if [ ! -d "/run/openbmc/" ]; then
	mkdir -p "/run/openbmc/"
fi

if [ "$2" == "shutdown_ack" ]; then
	shutdown_ack
elif [ "$2" == "status" ]; then
	power_status
elif [ "$2" == "force_reset" ]; then
	force_reset
elif [ "$2" == "host_reboot_wa" ]; then
	host_reboot_wa
elif [ "$2" == "soft_off" ]; then
	ret=$(soft_off)
	if [ "$ret" == 0 ]; then
		echo "The host is already softoff"
	else
		echo "Failed to softoff the host"
	fi
	exit "$ret";
else
	echo "Invalid parameter2=$2"
	usage;
fi

exit 0;
