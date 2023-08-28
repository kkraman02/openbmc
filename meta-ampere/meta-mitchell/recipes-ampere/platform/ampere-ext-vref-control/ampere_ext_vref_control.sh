#!/bin/bash

## NAME: The Ext Vref control script
## DESCRIPTION: The scrip will update the Vref threshold
#               and apply HW setting based on user setting. The rule will follow
#               logic as below
#  - S01_EXT_VREF_SEL GPIO = 1 => EXT_VREF = 700mV
#  - S01_EXT_VREF_SEL GPIO = 0 => EXT_VREF = 600mV
#               During the BMC booting, the BMC will call to this script
#               with the [ext_vref] parameter is empty.
#
## Syntax: ampere_ext_vref_control.sh [ext_vref]
## Example: ampere_ext_vref_control.sh 600

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-platform-init/gpio-lib.sh
source /usr/sbin/gpio-lib.sh

factor_unc=0.00102
factor_lnc=0.00098

# Entity inventory dbus sensor
s0_ext_vref_obj="S0_EXT_VREF"
s1_ext_vref_obj="S1_EXT_VREF"
s0_ext_vref_path="/xyz/openbmc_project/inventory/system/board/Mt_Mitchell_Motherboard/$s0_ext_vref_obj"
s1_ext_vref_path="/xyz/openbmc_project/inventory/system/board/Mt_Mitchell_Motherboard/$s1_ext_vref_obj"
entity_service="xyz.openbmc_project.EntityManager"
unc_interface="xyz.openbmc_project.Configuration.ADC.Thresholds1"
lnc_interface="xyz.openbmc_project.Configuration.ADC.Thresholds3"
entity_property="Value"

# RW partition
ext_vref_sel_file=/var/configuration/ext_vref_select

# RO partition
ext_vref_sel_default=/run/initramfs/ro/usr/share/ampere-ext-vref-control/ext_vref_sel_default

# S01_EXT_VREF_SEL = 1: EXT_VREF = 700mV
# S01_EXT_VREF_SEL = 0: EXT_VREF = 600V
hw_setting=(600 700)

# Entity-manager config json file
entity_config_file=/usr/share/entity-manager/configurations/mtmitchell_mb.json
system_config_file=/var/configuration/system.json
unc_direction_name="greater than"
lnc_direction_name="less than"
severity_non_critical=0
tmp_file=/tmp/tmp.json

# Power control dbus
chassis_service="xyz.openbmc_project.State.Chassis"
chassis_path="/xyz/openbmc_project/state/chassis0"
chassis_interface="xyz.openbmc_project.State.Chassis"
power_property="CurrentPowerState"

# Error code
cmdNotSupported=193
invalidVref=204
cmdInvalid4HostOn=213
unspecifiedError=255

help() {
	echo "Configure EXT VREF"
	echo "Usage: $(basename "$0") <Ext_Vref_Sel>"
	echo "Example :"
	echo "    $(basename "$0") 700"
}

set_property() {
	path=$1
	threshold=$2
	interface=$3

	cur_val=$(busctl get-property "$entity_service" "$path" "$interface" "$entity_property")
	if [ "$?" == '1' ]; then
		echo "Failed to access $path"
		exit $unspecifiedError
	fi

	cur_val=$(echo "$cur_val" | cut -d' ' -f2)
	if [ "$cur_val" != "$threshold" ]; then
		busctl set-property "$entity_service" "$path" "$interface" "$entity_property" d "$threshold"
		if [ "$?" == '1' ]; then
			echo "Failed to write to $entity_property at $path"
			exit $unspecifiedError
		fi
	fi
}

calculate_threshold() {
	ext_vref_input=$1
	idx=$2

	threshold=$(echo "$idx" "$ext_vref_input" | awk '{ printf "%.3f", $1 * $2 }')

	echo "$threshold"
}

update_vref_threshold() {
	ext_vref_input=$1

	unc_threshold=$(calculate_threshold "$ext_vref_input" "$factor_unc")
	lnc_threshold=$(calculate_threshold "$ext_vref_input" "$factor_lnc")

	set_property "$s0_ext_vref_path" "$lnc_threshold" "$lnc_interface"
	set_property "$s0_ext_vref_path" "$unc_threshold" "$unc_interface"
	set_property "$s1_ext_vref_path" "$lnc_threshold" "$lnc_interface"
	set_property "$s1_ext_vref_path" "$unc_threshold" "$unc_interface"
}

apply_hw_setting() {
	for key in "${!hw_setting[@]}"
	do
		if [ "$1" == "${hw_setting[$key]}" ]; then
			gpioset $(gpiofind ext-vref-sel)="$key"
			return
		fi
	done

	exit $invalidVref
}

read_hw_setting() {
	ext_vref_pin=$(gpio_name_get ext-vref-sel)
	if [ "$?" != '1' ]; then
		echo "${hw_setting["$ext_vref_pin"]}"
	fi
}

recover_ext_vref_config() {
	bootstatus=$(cat /sys/class/watchdog/watchdog0/bootstatus)
	if [ "$bootstatus" == '32' ]; then
		# Read from HW setting failed
		# Recover from default setting
		cp $ext_vref_sel_default $ext_vref_sel_file
		echo "Recover config file from default setting"
	else
		# Recover from HW setting
		ext_vref_from_hw=$(read_hw_setting)
		echo "$ext_vref_from_hw" > "$ext_vref_sel_file"
		echo "Recover config file from HW setting"
	fi
}

read_vref_json() {
	vref_obj=$1
	direction_name=$2
	severity=$3

	cmd=$(printf "jq '.[].Exposes.[] | select(.Name==\"%s\").Thresholds.[] | select((.Direction==\"%s\") and .Severity==%d).Value' %s" "$vref_obj" "$direction_name" "$severity" "$entity_config_file")
	threshold=$(eval "$cmd")
	if [ "$?" == '1' ]; then
		echo "Failed to read vref threshold from entity-manager config file"
		exit $unspecifiedError
	fi

	echo "$threshold"
}

update_vref_json() {
	vref_obj=$1
	direction_name=$2
	severity=$3
	threshold_input=$4

	cmd=$(printf "jq '(.[].Exposes.[] | select(.Name==\"%s\").Thresholds.[] | select((.Direction==\"%s\") and .Severity==%d).Value) |= %s' %s" "$vref_obj" "$direction_name" "$severity" "$threshold_input" "$entity_config_file")
	eval "$cmd" > "$tmp_file"
	if [ "$?" == '1' ]; then
		echo "Failed to update vref threshold to entity-manager config file"
		exit $unspecifiedError
	fi

	mv "$tmp_file" "$entity_config_file"
	if [ -s $system_config_file ]; then
		rm "$system_config_file"
	fi
}

update_entity_config()
{
	ext_vref_input=$1

	unc_threshold_input=$(calculate_threshold "$ext_vref_input" "$factor_unc")
	lnc_threshold_input=$(calculate_threshold "$ext_vref_input" "$factor_lnc")

	# Read Vref threshold from entity-manager config file
	s0_unc_threshold=$(read_vref_json "$s0_ext_vref_obj" "$unc_direction_name" "$severity_non_critical")
	s0_lnc_threshold=$(read_vref_json "$s0_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical")
	s1_unc_threshold=$(read_vref_json "$s1_ext_vref_obj" "$unc_direction_name" "$severity_non_critical")
	s1_lnc_threshold=$(read_vref_json "$s1_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical")

	# Update Vref threshold to entity-manager config file
	if [ "$unc_threshold_input" != "$s0_unc_threshold" ]; then
		update_vref_json "$s0_ext_vref_obj" "$unc_direction_name" "$severity_non_critical" "$unc_threshold_input"
	fi

	if [ "$unc_threshold_input" != "$s1_unc_threshold" ]; then
		update_vref_json "$s1_ext_vref_obj" "$unc_direction_name" "$severity_non_critical" "$unc_threshold_input"
	fi

	if [ "$lnc_threshold_input" != "$s0_lnc_threshold" ]; then
		update_vref_json "$s0_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical" "$lnc_threshold_input"
	fi

	if [ "$lnc_threshold_input" != "$s1_lnc_threshold" ]; then
		update_vref_json "$s1_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical" "$lnc_threshold_input"
	fi
}

control_vref_in_runtime() {
	ext_vref_input=$1

	# Check HOST status
	chassisstate=$(busctl get-property "$chassis_service" "$chassis_path" "$chassis_interface" "$power_property" | awk -F. '{print $NF}' | sed 's/.$//')
	echo "--- Current Chassis State: $chassisstate"
	if [ "$chassisstate" == 'On' ]; then
		exit $cmdInvalid4HostOn
	fi

	# Check vref input same as current value
	if [ -s $ext_vref_sel_file ]; then
		ext_vref_sel=$(cat "$ext_vref_sel_file")
		if [ "$ext_vref_sel" == "$ext_vref_input" ]; then
			exit 0
		fi
	fi

	# Apply HW setting
	apply_hw_setting "$ext_vref_input"
	if [ "$?" == '1' ]; then
		echo "Failed to apply HW setting"
		exit $unspecifiedError
	fi

	# Check Entity-manager config file
	update_entity_config "$ext_vref_input"
	# Update sensor threshold
	update_vref_threshold "$ext_vref_input"
	echo "Update the threshold sensor to $ext_vref_input mV"
	# Store user setting to ext_vref config
	echo "$ext_vref_input" > "$ext_vref_sel_file"
	echo "Store user setting $ext_vref_input to config file"
}

control_vref_in_bmc_booting() {
	# Check configs file is existed
	if [ ! -s $ext_vref_sel_file ]; then
		# Empty File, Recover mode
		recover_ext_vref_config
	fi

	ext_vref_sel=$(cat $ext_vref_sel_file)

	# Check Entity-manager config file
	update_entity_config "$ext_vref_sel"

	# Apply HW setting
	apply_hw_setting "$ext_vref_sel"
	if [ "$?" == '1' ]; then
		echo "Failed to apply HW setting"
		exit $unspecifiedError
	fi
}

ext_vref=$1

# Check the mainboard by board_id (i2c0, address 0x20)
board_id=$(i2cget -y -a 0 0x20 0x0 b)
if [ "$?" == '1' ]; then
	echo "Failed to read board_id from i2c"
	exit $unspecifiedError
fi

# BIT[2] of the Board_ID will define the board name
# 0: Mt.Mitchell
# 1: Mt.David

# BIT[5:4] Define xVTx
# XVT1: 00
# XVT2: 01
# XVT3: 10

# BIT[7:6] Define version
# EV : 00
# DV : 01
# PV : 10
mb_id_2=$(( board_id & 0x04 ))
md_id_5_4=$(( (board_id & 0x30)>>4 ))
md_id_7_6=$(( (board_id & 0xC0)>>6 ))
if [ "$mb_id_2" == '0' ]; then
	if [[ $md_id_7_6 -lt 2 ]]; then
		exit $cmdNotSupported
	fi

	if [[ $md_id_5_4 -lt 1 ]]; then
		exit $cmdNotSupported
	fi
fi

#Check pamarameter from user setting
if [ -n "$ext_vref" ]; then
	control_vref_in_runtime "$ext_vref"
else
	control_vref_in_bmc_booting
fi

exit 0
