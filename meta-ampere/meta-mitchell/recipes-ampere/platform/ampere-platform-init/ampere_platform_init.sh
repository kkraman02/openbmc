#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-platform-init/mtmitchell_platform_gpios_init.sh
# shellcheck source=meta-ampere/meta-common/recipes-ampere/platform/ampere-utils/utils-lib.sh
source /usr/sbin/platform_gpios_init.sh
source /usr/sbin/utils-lib.sh

function socket-based-fan-conf-update() {
    echo "Checking phosphor-fan configurations based on CPU 1 presence..."
    fanControlConfDir="/usr/share/phosphor-fan-presence/control/com.ampere.Hardware.Chassis.Model.MtMitchell"
    targetConf=groups.json

    if [[ "$(sx_present 1)" == "0" ]]; then
        refConf=groups_2p.json
        echo "CPU 1 is present"
        echo "Using fan configs for 2P at $fanControlConfDir/$refConf"
    else
        refConf=groups_1p.json
        echo "CPU 1 is NOT present"
        echo "Using fan configs for 1P at $fanControlConfDir/$refConf"
    fi

    if [ -f  "$fanControlConfDir/$refConf" ]; then
        cp "$fanControlConfDir/$refConf" "$fanControlConfDir/$targetConf"
    else
        echo "The reference fan config $fanControlConfDir/$refConf does not exist!!"
    fi
}


#pre platform init function. implemented in platform_gpios_init.sh
pre-platform-init

# =======================================================
# Setting default value for device sel and mux
bootstatus=$(cat /sys/class/watchdog/watchdog0/bootstatus)
if [ "$bootstatus" == '32' ]; then
    echo "CONFIGURE: gpio pins to output high after AC power"
    for gpioName in "${output_high_gpios_in_ac[@]}"; do
        gpioset $(gpiofind "$gpioName")=1
    done
    echo "CONFIGURE: gpio pins to output low after AC power"
    for gpioName in "${output_low_gpios_in_ac[@]}"; do
        gpioset $(gpiofind "$gpioName")=0
    done
    echo "CONFIGURE: gpio pins to input after AC power"
    for gpioName in "${input_gpios_in_ac[@]}"; do
        gpioget $(gpiofind "$gpioName")
    done
fi

# =======================================================
# Setting default value for others gpio pins
echo "CONFIGURE: gpio pins to output high"
for gpioName in "${output_high_gpios_in_bmc_reboot[@]}"; do
    gpioset $(gpiofind "$gpioName")=1
done
echo "CONFIGURE: gpio pins to output low"
for gpioName in "${output_low_gpios_in_bmc_reboot[@]}"; do
    gpioset $(gpiofind "$gpioName")=0
done
echo "CONFIGURE: gpio pins to input"
for gpioName in "${input_gpios_in_bmc_reboot[@]}"; do
    gpioget $(gpiofind "$gpioName")
done

socket-based-fan-conf-update

#post platform init function. implemented in platform_gpios_init.sh
post-platform-init

exit 0
