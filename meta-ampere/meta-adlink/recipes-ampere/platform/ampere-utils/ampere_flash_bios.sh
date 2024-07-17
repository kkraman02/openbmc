#!/bin/bash
#
# Copyright (c) 2021 Ampere Computing LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# shellcheck disable=SC2046

do_flash () {
	# Check the PNOR partition available
	HOST_FW_MTD=$(< /proc/mtd grep "\"pnor-uefi\"" | sed -n 's/^\(.*\):.*/\1/p')
	HOST_FULL_MTD=$(< /proc/mtd grep "\"pnor\"" | sed -n 's/^\(.*\):.*/\1/p')
	if [ -z "$HOST_FW_MTD" ];
	then
		# Check the ASpeed SMC driver bound before
		HOST_SPI=/sys/bus/platform/drivers/spi-aspeed-smc/1e630000.spi
		if [ -d "$HOST_SPI" ]; then
			echo "Unbind the ASpeed SMC driver"
			echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/unbind
			sleep 2
		fi

		# If the PNOR partition is not available, then bind again driver
		echo "--- Bind the ASpeed SMC driver"
		echo 1e630000.spi > /sys/bus/platform/drivers/spi-aspeed-smc/bind
		sleep 2

		HOST_FW_MTD=$(< /proc/mtd grep "\"pnor-uefi\"" | sed -n 's/^\(.*\):.*/\1/p')
		HOST_FULL_MTD=$(< /proc/mtd grep "\"pnor\"" | sed -n 's/^\(.*\):.*/\1/p')
		if [ -z "$HOST_FW_MTD" ];
		then
			echo "Fail to probe Host SPI-NOR device"
			exit 1
		fi
	fi

	extension=${IMAGE##*.}

	if [ "$extension" = "img" ]; then
		echo "--- Flashing firmware to @/dev/$HOST_FW_MTD"
		flashcp.mtd-utils -p -v "$IMAGE" /dev/"$HOST_FW_MTD"
	elif [ "$extension" = "bin" ]; then
                echo "--- Flashing firmware to @/dev/$HOST_FULL_MTD"
                flashcp.mtd-utils -p -v "$IMAGE" /dev/"$HOST_FULL_MTD"
	else
		echo "ERROR: Unknown file extension \"$extension\""
	fi
}


if [ $# -eq 0 ]; then
	echo "Usage: $(basename "$0") <UEFI image file>"
	exit 0
fi

IMAGE="$1"
if [ ! -f "$IMAGE" ]; then
	echo "The image file $IMAGE does not exist"
	exit 1
fi

# Turn off the Host if it is currently ON
chassisstate=$(ipmitool power status | awk '{print $4}')
echo "--- Current Chassis State: $chassisstate"
if [ "$chassisstate" == 'on' ];
then
	echo "--- Turning the Chassis off"
	ipmitool power off

	# Wait 60s until Chassis is off
	cnt=30
	while [ "$cnt" -gt 0 ];
	do
		cnt=$((cnt - 1))
		sleep 2
		# Check if HOST was OFF
		chassisstate_off=$(ipmitool power status | awk '{print $4}')
		if [ "$chassisstate_off" != 'on' ];
		then
			break
		fi

		if [ "$cnt" == "0" ];
		then
			echo "--- Error : Failed turning the Chassis off"
			exit 1
		fi
	done
fi

# Switch the host SPI bus to BMC"
echo "--- Switch the host SPI bus to BMC."
if ! gpioset $(gpiofind spi0-program-sel)=0; then
	echo "ERROR: Switch the host SPI bus to BMC. Please check gpio state"
	exit 1
fi

# Flash the firmware
do_flash

# Switch the host SPI bus to HOST."
echo "--- Switch the host SPI bus to HOST."
if ! gpioset $(gpiofind spi0-program-sel)=1; then
	echo "ERROR: Switch the host SPI bus to HOST. Please check gpio state"
	exit 1
fi

if [ "$chassisstate" == 'on' ];
then
	sleep 5
	echo "Turn on the Host"
	ipmitool power on
fi
