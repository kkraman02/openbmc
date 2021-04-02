#!/bin/bash
#ampere_platform_config.sh is platform configuration file

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-platform-init/gpio-lib.sh
source /usr/sbin/gpio-lib.sh

function s1_present()
{
    state=$(gpio_name_get presence-cpu1)
    if [ "$state" == "0" ]; then
        echo 1
    fi
    echo 0
}

function s0_mctp_ready()
{
	if i2cget -f -y 3 0x4f 0; then
		echo 1
	fi
	echo 0
}

function s1_mctp_ready()
{
	state=$(gpioget $(gpiofind s1-pcp-pgood))
	if [ "$state" == "1" ]; then
		if i2cget -f -y 3 0x4e 0; then
			echo 1
		fi
	fi
	echo 0
}

if [ "$1" == "s1_present" ]; then
	ret=$(s1_present)
	echo "$ret"
elif [ "$1" == "s0_mctp_ready" ]; then
	ret=$(s0_mctp_ready)
	echo "$ret"
elif [ "$1" == "s1_mctp_ready" ]; then
	ret=$(s1_mctp_ready)
	echo "$ret"
fi

exit 0
