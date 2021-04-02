#!/bin/bash

# shellcheck disable=SC2046
# shellcheck disable=SC2005
# shellcheck disable=SC2086
# shellcheck disable=SC2091
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-misc/power-manager/dbus_utils.sh
source /usr/sbin/dbus_utils.sh

pldm_service="xyz.openbmc_project.PLDM"
s0_plimit_object_path="/xyz/openbmc_project/sensors/power/S0_PLimit"
s1_plimit_object_path="/xyz/openbmc_project/sensors/power/S1_PLimit"
s0_dram_throt_en_object_path="/xyz/openbmc_project/sensors/oem/S0_DRAM_MThrotEn"
s1_dram_throt_en_object_path="/xyz/openbmc_project/sensors/oem/S1_DRAM_MThrotEn"

virtual_sensors_service="xyz.openbmc_project.VirtualSensor"
total_power_object_path="/xyz/openbmc_project/sensors/power/total_power"

value_interface="xyz.openbmc_project.Sensor.Value"
value_property="Value"
min_value_property="MinValue"
max_value_property="MaxValue"

power_manager_service="xyz.openbmc_project.Control.power.manager"
power_cap_object_path="/xyz/openbmc_project/control/power/manager/cap"
power_cap_interface="xyz.openbmc_project.Control.Power.Cap"
power_cap_property="PowerCap"
except_act_property="ExceptionAction"

cpu1_presence_flag="false"
state=$(gpioget $(gpiofind presence-cpu1))
if [ "$state" == "0" ]
then
    cpu1_presence_flag="true"
fi

function get_Current_Sys_Power_Consumed()
{
    echo $(get_dbus_property ${virtual_sensors_service} \
        ${total_power_object_path} ${value_interface} ${value_property})
}

function get_System_Power_Limit()
{
    echo $(get_dbus_property ${power_manager_service} \
        ${power_cap_object_path} ${power_cap_interface} ${power_cap_property})
}

function get_System_Exception_Action()
{
    echo $(get_dbus_property ${power_manager_service} \
        ${power_cap_object_path} ${power_cap_interface} ${except_act_property})
}

function get_Plimit_Sensor_155()
{
    echo $(get_dbus_property ${pldm_service} \
        ${s0_plimit_object_path} ${value_interface} ${value_property})
}

function get_Plimit_Sensor_155_MinValue()
{
    echo $(get_dbus_property ${pldm_service} \
        ${s0_plimit_object_path} ${value_interface} ${min_value_property})
}

function get_Plimit_Sensor_155_MaxValue()
{
    echo $(get_dbus_property ${pldm_service} \
        ${s0_plimit_object_path} ${value_interface} ${max_value_property})
}

function get_DRAM_Max_Throttle_Enable()
{
    echo $(get_dbus_property ${pldm_service} \
        ${s0_dram_throt_en_object_path} ${value_interface} ${value_property})
}

function set_Plimit_Sensor_155()
{
    value=$1

    $(set_dbus_property ${pldm_service} ${s0_plimit_object_path} \
        ${value_interface} ${value_property} "d" ${value})

    if [ $cpu1_presence_flag == "true" ]
    then
        $(set_dbus_property ${pldm_service} ${s1_plimit_object_path} \
            ${value_interface} ${value_property} "d" ${value})
    fi
}

function set_DRAM_Max_Throttle_Enable()
{
    value=$1

    $(set_dbus_property ${pldm_service} ${s0_dram_throt_en_object_path} \
        ${value_interface} ${value_property} "d" ${value})

    if [ $cpu1_presence_flag == "true" ]
    then
        $(set_dbus_property ${pldm_service} ${s1_dram_throt_en_object_path} \
            ${value_interface} ${value_property} "d" ${value})
    fi
}

function add_OEM_Action_Redfish_Log()
{
    redfish_args=$1

    logger-systemd --journald << EOF
MESSAGE=
PRIORITY=
SEVERITY=
REDFISH_MESSAGE_ID=OpenBMC.0.1.AmpereEvent
REDFISH_MESSAGE_ARGS=${redfish_args}
EOF
}