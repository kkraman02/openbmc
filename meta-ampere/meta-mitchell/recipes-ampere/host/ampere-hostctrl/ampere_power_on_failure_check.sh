#!/bin/bash

# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-platform-init/gpio-lib.sh
source /usr/sbin/gpio-lib.sh

function check_cpu_presence()
{
	# Check CPU presence, identify whether it is 1P or 2P system
	s0_presence=$(gpio_name_get presence-cpu0)
	s1_presence=$(gpio_name_get presence-cpu1)
	if [ "$s0_presence" == "0" ] && [ "$s1_presence" == "0" ]; then
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 2 Processor"
	elif [ "$s0_presence" == "0" ]; then
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 1 Processor"
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "No Processor is present"
	fi
}

function check_power_state()
{
	echo "ATX power good checking"
	state=$(gpio_name_get power-chassis-good)
	if [ "$state" == "0" ]
	then
		echo "Error: Failed to turn on ATX Power"
		ampere_add_redfishevent.sh OpenBMC.0.1.PowerSupplyPowerGoodFailed.Critical "60000"
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "ATX Power is ON"
	fi

	echo "Soc power good checking"
	state=$(gpio_name_get s0-soc-pgood)
	if [ "$state" == "0" ]
	then
		echo "Error: Soc domain power failure"
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereCritical.Critical "Soc domain, power failure"
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "SoC power domain is ON"
	fi

	echo "PCP power good checking"
	state=$(gpio_name_get host0-ready)
	if [ "$state" == "0" ]
	then
		echo "Error: PCP domain power failure. Power off Host"
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereCritical.Critical "PCP domain, power failure"
		busctl set-property xyz.openbmc_project.State.Chassis \
			/xyz/openbmc_project/state/chassis0 \
			xyz.openbmc_project.State.Chassis RequestedPowerTransition s \
			xyz.openbmc_project.State.Chassis.Transition.Off
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "PCP power is ON"
	fi
}

# Check current Host status. Do nothing when the Host is currently ON
st=$(busctl get-property xyz.openbmc_project.State.Host \
	/xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
	CurrentHostState | cut -d"." -f6)
if [ "$st" == "Running\"" ]; then
	exit 0
fi

action=$1

if [ "$action" == "check_cpu" ]
then
	echo "Check CPU presence"
	check_cpu_presence
elif [ "$action" == "check_power" ]
then
	echo "Check Power state"
	check_power_state
fi

exit 0