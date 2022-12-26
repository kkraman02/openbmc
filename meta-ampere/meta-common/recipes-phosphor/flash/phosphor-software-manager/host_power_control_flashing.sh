#!/bin/bash

declare -a power_on_targets=(
			     obmc-host-reboot@0.target
			     obmc-host-warm-reboot@0.target
			     obmc-host-force-warm-reboot@0.target
			    )

systemd1_service="org.freedesktop.systemd1"
systemd1_object_path="/org/freedesktop/systemd1"
systemd1_manager_interface="org.freedesktop.systemd1.Manager"
mask_method="MaskUnitFiles"
unmask_method="UnmaskUnitFiles"

function mask_reboot_targets()
{
	# To prevent reboot actions during flashing phase,
	# this function will mask all reboot targets
	for target in "${power_on_targets[@]}"
	do
		busctl call $systemd1_service $systemd1_object_path $systemd1_manager_interface \
			$mask_method asbb 1 "$target" false true
	done
}

function unmask_reboot_targets()
{
	# Allow reboot targets work normal after flashing done
	for target in "${power_on_targets[@]}"
	do
		busctl call $systemd1_service $systemd1_object_path $systemd1_manager_interface \
			$unmask_method asb 1 "$target" false
	done
}

purpose=$1
allow=$2

if [ "$purpose" == "reboot" ]
then 
	if [ "$allow" == "false" ]
	then
		mask_reboot_targets
	else
		unmask_reboot_targets
	fi
fi
