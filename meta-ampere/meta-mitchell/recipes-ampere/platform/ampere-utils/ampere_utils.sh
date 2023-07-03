#!/bin/bash
# ampere_utils.sh is ampere utilities platform scripts
# Usage:
# ampere_utils.sh host state on/go-to-off

# shellcheck disable=SC2046

ERR_SUSSESS="0"
ERR_FAILURE="1"
function is_host_going_to_off()
{
	cc="false"
	cnt=5
	outMsg=""
	while [ $cnt -gt 0 ];
	do
		st=$(busctl call xyz.openbmc_project.State.Host \
				/xyz/openbmc_project/state/host0 org.freedesktop.DBus.Properties \
				Get ss xyz.openbmc_project.State.Host \
				CurrentHostState | cut -d"." -f6)
		if [[ "$st" != "Running\"" ]]; then
			# In bmc reboot the host state will change from Running to empty
			if [[ "$st" != "" ]]; then
				cc="true"
			fi
			break
		fi
		sleep 1
		cnt=$((cnt - 1))
	done
	echo "$cc"
}

function host_state_handler()
{
	cc=$ERR_FAILURE
	if [ "$1" == "go-to-off" ]; then
		st=$(is_host_going_to_off)
		if [ "$st" == "true" ]; then
			rm -rf /var/ampere/fault_RAS_UE
			rm -rf /tmp/gpio_fault
			cc=$ERR_SUSSESS
		fi
	fi
	echo "$cc"
}

function host_action_handler()
{
	cc=$ERR_FAILURE
	if [ "$1" == "state" ]; then
		cc=$(host_state_handler "$2")
	fi
	echo "$cc"
}

if [ "$1" == "host" ]; then
	cc=$(host_action_handler "$2" "$3")
	echo "ampere_utils.sh $1 $2 $3 finished with complete code $cc"
fi

exit 0
