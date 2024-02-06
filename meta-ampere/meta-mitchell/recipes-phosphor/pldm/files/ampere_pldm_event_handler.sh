#!/bin/bash

# Usage of this utility
# sensorEvent : 0x0
#       stateSensorState : 0
#       numericSensorState : 1
#       sensorOpState : 2
# ampere_pldm_event_handler.sh sensorEvent stateSensorState tid sensorID sensorOffset eventState previousEventState
# ampere_pldm_event_handler.sh sensorEvent numericSensorState tid sensorID eventState previousEventState sensorDataSize presentReading
# ampere_pldm_event_handler.sh sensorEvent sensorOpState tid sensorID presentOpState previousOpState

# pldmMessagePollEvent : 0x5
# ampere_pldm_event_handler.sh pldmMessagePollEvent tid formatVersion eventID dataTransferHandle

#DIMM number
DIMM_NUMBER=24

#socket
SOCKET_0_TID=1
SOCKET_1_TID=2
SOCKET_0_NAME="SOCKET0"
SOCKET_1_NAME="SOCKET1"
S0_NAME="S0"
S1_NAME="S1"

# Indicates an Ampere OK event. Used for the notification.
REDFISH_MSG_AMPERE_EVENT="OpenBMC.0.1.AmpereEvent"
#Indicates an Ampere warning event. Used for the warning message.
REDFISH_MSG_AMPERE_WARNING="OpenBMC.0.1.AmpereWarning"
#Indicates an Ampere critical event. Used for the critical errors (CE/UE).
REDFISH_MSG_AMPERE_CRITICAL="OpenBMC.0.1.AmpereCritical"

#Event type
SENSOR_EVENT=0
PLDM_MESSAGE_POLL_EVENT=5

# Sensor Event Class
SENSOR_OP_STATE=0
STATE_SENSOR_STATE=1
NUMERIC_SENSOR_STATE=2

# Sensor NAME from pldm dbus sensor interface -> sensorID
DDR_STATUS=51
PCP_VR_STATE=75
SOC_VR_STATE=80
DPHY_VR1_STATE=85
DPHY_VR2_STATE=90
D2D_VR_STATE=95
IOC_VR1_STATE=100
IOC_VR2_STATE=105
PCI_D_VR_STATE=110
PCI_A_VR_STATE=115
PCIE_HOT_PLUG=169
BOOT_OVERALL=175

# RAS UE variables
UE_SENSOR_ID=(192 194 196 198)

WARNING_MSG="WARN_MSG"
ERROR_MSG="ERROR_MSG"

#format: add_OEM_Action_Redfish_Log $redfish_msg_id $redfish_args
function add_OEM_Action_Redfish_Log()
{
    redfish_msg=$1
    redfish_msg_id=$2
    redfish_args=$3

    logger --journald << EOF
MESSAGE=${redfish_msg}
PRIORITY=2
SEVERITY=
REDFISH_MESSAGE_ID=${redfish_msg_id}
REDFISH_MESSAGE_ARGS=${redfish_args}
EOF
}

#format: sensor_event_state_sensor_state $tid $sensorId $sensorOffset $eventState $previousEventState
function sensor_event_state_sensor_state() {
    local tid=$1
    local sensorId=$(($2))
    local sensorOffset=$3
    local eventState=$4
    local previousEventState=$5
    echo "INFO: SENSOR_EVENT : STATE_SENSOR_STATE: tid $tid sensorId $sensorId sensorOffset $sensorOffset eventState $eventState  previousEventState $previousEventState"
}

#format: sensor_id_to_string $sensorId
function sensor_id_to_string()
{
    local sensorId=$(($1))
    if [[ $sensorId -ge 4 ]] && [[ $sensorId -le 34 ]] && [[ $((sensorId % 2)) -eq 0 ]]; then
        echo "DIMM$((($1-4)/2)) Status"
        exit 0
    fi
    case $sensorId in
        $((DDR_STATUS)) )
            echo "DDR Status"
            exit 0
            ;;
        $((PCP_VR_STATE)) )
            echo "PCP VR STATE"
            exit 0
            ;;
        $((SOC_VR_STATE)) )
            echo "SOC VR STATE"
            exit 0
            ;;
        $((DPHY_VR1_STATE)) )
            echo "DPHY VR1 STATE"
            exit 0
            ;;
        $((DPHY_VR2_STATE)) )
            echo "DPHY VR2 STATE"
            exit 0
            ;;
        $((D2D_VR_STATE)) )
            echo "D2D VR STATE"
            exit 0
            ;;
        $((IOC_VR1_STATE)) )
            echo "IOC VR1 STATE"
            exit 0
            ;;
        $((IOC_VR2_STATE)) )
            echo "IOC VR2 STATE"
            exit 0
            ;;
        $((PCI_D_VR_STATE)) )
            echo "PCI D VR STATE"
            exit 0
            ;;
        $((PCI_A_VR_STATE)) )
            echo "PCI A VR STATE"
            exit 0
            ;;
        *)
            echo "Unsupported EventId $sensorId"
            exit 0
            ;;
    esac
}

#format: dimm_mask_to_string $socketTid
function tid_to_socket_string()
{
    local str="$SOCKET_0_NAME"
    if [[ $1 -eq $SOCKET_1_TID ]]; then
        str="$SOCKET_1_NAME"
    fi
    echo "$str"
}

#format: dimm_mask_to_string $3byteDimmMask
function dimm_mask_to_string()
{
    local failDimmIdx=$(($1))
    local str=""

    for (( i=0; i<$((DIMM_NUMBER)); i++ ));
    do
        local isFailed=$(( failDimmIdx & (1 << i) ))
        if [[ isFailed -ne 0 ]]; then
            if [[ "$str" == "" ]]; then
                str="dimm#$i"
            else
                str="$str dimm#$i"
            fi
        fi
    done
    echo "$str"
}

#format: dimm_training_failure_to_string $byte3 $byte2 $byte1 $byte0 $presentReading
function dimm_training_failure_to_string()
{
    local str=""
    local byte3=$(($1))
    local presentReading=$(($4))
    local byte0_bit10=$(($3 & 0x03)) #byte0 bit[1:0]
    local byte0_bit42=$(($3 & 0x1C)) #byte0 bit[4:2]
    local byte1_bit30=$(($2 & 0x0F)) #byte1 bit[3:0]
    local byte1_bit4=$(($2 & 0x10)) #byte1 bit[4]
    local byte1_bit5=$(($2 & 0x20)) #byte1 bit[5]
    local byte2_bit30=$(($1 & 0x0F)) #byte2 bit[3:0]

    if [[ $byte0_bit10 -eq 1 ]]; then
        str=$(printf "PHY training failure: MCU rank index (%d)" $byte0_bit42)
        str=$(printf "%s Slice number (0x%02x)" "$str" $byte1_bit30)
        if [[ $byte1_bit4 -eq 0 ]]; then
            str=$(printf "%s Upper nibble error status:(%s)" "$str" "No error")
        else
            str=$(printf "%s Upper nibble error status:(%s)" "$str" "Found no rising edge")
        fi
        if [[ $byte1_bit5 -eq 0 ]]; then
            str=$(printf "%s Lower nibble error status:(%s)" "$str" "No error")
        else
            str=$(printf "%s Lower nibble error status:(%s)" "$str" "Found no rising edge")
        fi
        str="$str Failure syndrome 0"
        case $byte2_bit30 in
            0)
                str="$str (N/A)"
                ;;
            1)
                str="$str (PHY training setup failure)"
                ;;
            2)
                str="$str (CA leveling)"
                ;;
            3)
                str="$str (PHY write level failure - see syndrome 1)"
                ;;
            4)
                str="$str (PHY read gate leveling failure)"
                ;;
            5)
                str="$str (PHY read level failure)"
                ;;
            6)
                str="$str (Write DQ leveling)"
                ;;
            7)
                str="$str (PHY SW training failure)"
                ;;
            *)
                str=$(printf "%s (Unknown code - 0x%02x)" "$str" $byte3)
                ;;
        esac
    elif [[ $byte0_bit10 -eq 2 ]]; then
        str=$(printf "DIMM training failure: MCU rank index (%d)" $byte0_bit42)
        str=$(printf "%s Slice number (0x%02x)" "$str" $byte1_bit30)
        if [[ $byte1_bit4 -eq 0 ]]; then
            str=$(printf "%s Upper nibble error status:(%s)" "$str" "No error")
        else
            str=$(printf "%s Upper nibble error status:(%s)" "$str" "Found no rising edge")
        fi
        if [[ $byte1_bit5 -eq 0 ]]; then
            str=$(printf "%s Lower nibble error status:(%s)" "$str" "No error")
        else
            str=$(printf "%s Lower nibble error status:(%s)" "$str" "Found no rising edge")
        fi
        str="$str Failure syndrome 0"
        case $byte2_bit30 in
            0)
                str="$str (N/A)"
                ;;
            1)
                str="$str (DRAM VREFDQ training failure)"
                ;;
            2)
                str="$str (LRDIMM DB training failure)"
                ;;
            3)
                str="$str (LRDRIMM DB training failure)"
                ;;
            *)
                str=$(printf "%s (Unknown code - 0x%02x)" "$str" $byte3)
                ;;
        esac
    else
        str=$(printf "Unknown present reading (0x%08x)" $presentReading)
    fi
    echo "$str"
}

#format: dimm_present_reading_to_message $presentReading
function dimm_present_reading_to_message()
{
    local presentReading=$(($1))
    local byte0=$(( presentReading & 0x000000ff ))
    local byte1=$(( (presentReading & 0x0000ff00) >> 8 ))
    local byte2=$(( (presentReading & 0x00ff0000) >> 16 ))
    local byte3=$(( (presentReading & 0xff000000) >> 24 ))
    local byte012=$(( presentReading & 0xffffff ))
    local str=""

    case $byte3 in
        $((0x01)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "Installed and no error"
                exit 0
            fi
            ;;
        $((0x02)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:Not installed"
                exit 0
            fi
            ;;
        $((0x07)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:Other failure"
                exit 0
            fi
            ;;
        $((0x10)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "Installed but disabled"
                exit 0
            fi
            ;;
        $((0x12)) )
            echo "$ERROR_MSG:$(dimm_training_failure_to_string "$byte2" "$byte1" "$byte0" "$presentReading")"
            exit 0
            ;;
        $((0x13)) )
            if [[ $byte1 -eq 0 ]] && [[ $byte2 -eq 0 ]]; then
                local isFailed=$(( byte0 & 0x1 ))
                if [[ isFailed -ne 0 ]]; then
                    echo "$ERROR_MSG:PMIC high temp condition"
                else
                    echo "$ERROR_MSG:PMIC error status"
                fi
                exit 0
            fi
            ;;
        $((0x14)) )
            if [[ $byte1 -eq 0 ]] && [[ $byte2 -eq 0 ]]; then
                local isFailed=$(( byte0 & 0x1 ))
                if [[ isFailed -ne 0 ]]; then
                    str="$ERROR_MSG:TS0"
                fi
                isFailed=$(( byte0 & 0x2 ))
                if [[ isFailed -ne 0 ]]; then
                    if [[ "$str" == "" ]]; then
                        str="$ERROR_MSG:TS1"
                    else
                        str="$str and TS1"
                    fi
                fi
                echo "$str exceeds its high temperature threshold"
                exit 0
            fi
            ;;
        $((0x15)) )
            if [[ $byte1 -eq 0 ]] && [[ $byte2 -eq 0 ]]; then
                local isFailed=$(( byte0 & 0x1 ))
                if [[ isFailed -ne 0 ]]; then
                    echo "$ERROR_MSG:SPD/HUB hight temp condition"
                else
                    echo "$ERROR_MSG:SPD error status"
                fi
                exit 0
            fi
            ;;
    esac

    echo "$ERROR_MSG:$(printf "Unknown present reading (0x%08x)" $presentReading)"
    exit 0
}

#format: ddr_present_reading_to_message $presentReading
function ddr_present_reading_to_message()
{
    local presentReading=$(($1))
    local byte0=$(( presentReading & 0x000000ff ))
    local byte1=$(( (presentReading & 0x0000ff00) >> 8 ))
    local byte2=$(( (presentReading & 0x00ff0000) >> 16 ))
    local byte3=$(( (presentReading & 0xff000000) >> 24 ))
    local byte012=$(( presentReading & 0xffffff ))
    local str=""

    case $byte3 in
        $((0x01)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "Installed and no error"
                exit 0
            fi
            ;;
        $((0x04)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:ECC initialization failure"
                exit 0
            fi
            ;;
        $((0x05)) )
            echo "$ERROR_MSG:Configuration failure: $(dimm_mask_to_string "$byte012")"
            exit 0
            ;;
        $((0x06)) )
            echo "$ERROR_MSG:Training failure: $(dimm_mask_to_string "$byte012")"
            exit 0
            ;;
        $((0x07)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:Other failure"
                exit 0
            fi
            ;;
        $((0x08)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:Boot failure due to no valid configuration."
                exit 0
            fi
            ;;
        $((0x09)) )
            if [[ $byte012 -eq 0 ]]; then
                echo "$ERROR_MSG:DDR failsafe activated but boot success with the next valid configuration"
                exit 0
            fi
            ;;
    esac

    echo "$ERROR_MSG:$(printf "Unknown present reading (0x%08x)" $presentReading)"
    exit 0
}

#format: dimm_ddr_status $tid $sensorId $presentReading
function dimm_ddr_status()
{
    local description=""
    local temp=""
    local sensorId=$(($2))
    temp=$(tid_to_socket_string "$1")
    description="$description $temp"
    temp=$(sensor_id_to_string "$sensorId")
    description="$description $temp"
    if [[ $sensorId -ge 4 ]] && [[ $sensorId -le 34 ]] && [[ $((sensorId % 2)) -eq 0 ]]; then
        temp=$(dimm_present_reading_to_message "$3")
    elif [[ $sensorId -eq $DDR_STATUS ]]; then
        temp=$(ddr_present_reading_to_message "$3")
    fi

    local sRedfishMsgId="$REDFISH_MSG_AMPERE_EVENT"
    if [[ "$description" == *"$ERROR_MSG:"* ]]; then
        sRedfishMsgId="$REDFISH_MSG_AMPERE_CRITICAL"
        # AmpereCritical Redfish registry accept two argument, "," is need
        description="$description,$temp"
        description=${description/"$ERROR_MSG:"/""}
    else
        # AmpereEvent Redfish registry accept one argument
        description="$description $temp"
    fi
    # Add redfish log
    add_OEM_Action_Redfish_Log "${description}" "${sRedfishMsgId}" "${description}"
}

#format: vrd_present_reading_to_message $presentReading
function vrd_present_reading_to_message()
{
    local presentReading=$(($1))
    local byte0=$(( presentReading & 0x000000ff ))
    local byte23=$(( (presentReading & 0xffff0000) >> 16 ))
    local str=""

    local mask=$(( byte0 & 0x2 ))
    if [[ mask -ne 0 ]]; then
        str="$ERROR_MSG:A VR critical"
    fi
    mask=$(( byte0 & 0x1 ))
    if [[ mask -ne 0 ]]; then
        if [[ "$str" == "" ]]; then
            str="$WARNING_MSG:A VR warning"
        else
            str="$str and A VR warning"
        fi
    fi
    str="$str condition observed"
    str=$(printf "%s VR status:(0x%04x)" "$str" $byte23)
    if [[ "$str" != "" ]]; then
        echo "$str"
        exit 0
    fi

    echo "$ERROR_MSG:$(printf "Unknown present reading (0x%08x)" $presentReading)"
    exit 0
}

#format: vrd_state $tid $sensorId $presentReading
function vrd_state()
{
    local description=""
    local temp=""
    local sensorId=$(($2))
    temp=$(tid_to_socket_string "$1")
    description="$description $temp"
    temp=$(sensor_id_to_string "$sensorId")
    description="$description $temp"
    temp=$(vrd_present_reading_to_message "$3")

    local sRedfishMsgId="$REDFISH_MSG_AMPERE_EVENT"
    if [[ "$description" == *"$WARNING_MSG:"* ]]; then
        sRedfishMsgId="$REDFISH_MSG_AMPERE_WARNING"
        description="$description,$temp"
        description=${description/"$WARNING_MSG:"/""}
    elif [[ "$description" == *"$ERROR_MSG:"* ]]; then
        sRedfishMsgId="$REDFISH_MSG_AMPERE_CRITICAL"
        description="$description,$temp"
        description=${description/"$ERROR_MSG:"/""}
    else
        description="$description $temp"
    fi
    # Add redfish log
    add_OEM_Action_Redfish_Log "${description}" "${sRedfishMsgId}" "${description}"
}

#format: map_boot_status $byte3 $byte2 $byte1 $byte0
function map_boot_status() {
    local byte2=$(($2))
    local byte3=$(($1))
    local byte0=$(($4))
    #case compare string
    case $byte3 in
        $((0x90)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:SECpro boot failed"
            else
                case $byte0 in
                    1)
                        echo "SECpro completed"
                        ;;
                    *)
                        echo "SECpro booting"
                        ;;
                esac
            fi
            ;;
        $((0x91)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:Mpro boot failed"
            else
                case $byte0 in
                    1)
                        echo "Mpro completed"
                        ;;
                    *)
                        echo "Mpro booting"
                        ;;
                esac
            fi
            ;;
        $((0x92)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:ATF BL1 boot failed"
            else
                case $byte0 in
                    1)
                        echo "ATF BL1 completed"
                        ;;
                    *)
                        echo "ATF BL1 booting"
                        ;;
                esac
            fi
            ;;
        $((0x93)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:ATF BL2 boot failed"
            else
                case $byte0 in
                    1)
                        echo "ATF BL2 completed"
                        ;;
                    *)
                        echo "ATF BL2 booting"
                        ;;
                esac
            fi
            ;;
        $((0x94)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:DDR initialization failed"
            else
                case $byte0 in
                    1)
                        echo "DDR initialization completed"
                        ;;
                    *)
                        echo "DDR initialization started"
                        ;;
                esac
            fi
            ;;
        $((0x95)))
            case $byte0 in
                0)
                    echo "DDR training progress started"
                    ;;
                1)
                    echo "DDR training in-progress $3%"
                    ;;
                2)
                    echo "DDR training progress completed"
                    ;;
            esac
            ;;
        $((0x96)) | $((0x99)) )
            local byte1=$(($3))
            local failDimmIdx=$(( (byte0) + (byte1 << 8) + (byte2 << 16) ))
            local sSocket="$SOCKET_1_NAME"
            #0x96 == 150
            if [[ $byte3 -eq $((0x96)) ]]; then
                sSocket="$SOCKET_0_NAME"
            fi
            local sState=" Training progress failed at DIMMs:"

            dimmFaileds=$(dimm_mask_to_string "$failDimmIdx")
            echo "$ERROR_MSG:$sSocket $sState $dimmFaileds"
            ;;
        $((0x97)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:ATF BL31 boot failed"
            else
                case $byte0 in
                    1)
                        echo "ATF BL31 completed"
                        ;;
                    *)
                        echo "ATF BL31 booting"
                        ;;
                esac
            fi
            ;;
        $((0x98)))
            if [[ $byte2 -eq $((0x81)) ]]; then
                echo "$ERROR_MSG:ATF BL32 boot failed"
            else
                case $byte0 in
                    1)
                        echo "ATF BL32 completed"
                        ;;
                    *)
                        echo "ATF BL32 booting"
                        ;;
                esac
            fi
            ;;
    esac
}

#format: boot_overall $tid $presentReading
function boot_overall()
{
    local presentReading=$(($2))

    local byte0=$(( presentReading & 0x000000ff ))
    local byte1=$(( (presentReading & 0x0000ff00) >> 8 ))
    local byte2=$(( (presentReading & 0x00ff0000) >> 16 ))
    local byte3=$(( (presentReading & 0xff000000) >> 24 ))

    local description=""
    local temp=""
    if [[ $byte3 -le $((0x7f)) ]]; then
        description="ATF BL33 (UEFI) booting status ="
        temp=$(printf "Segment (0x%08x)" $presentReading)
        description="$description $temp"
        temp=$(printf "Status Class (0x%02x)" $byte3)
        description="$description $temp"
        temp=$(printf "Status SubClass (0x%02x)" $byte2)
        description="$description $temp"
        temp=$(printf "Operation Code (0x%04x)" $(( (presentReading & 0xffff0000) >> 16 )))
        description="$description $temp"
    else
        temp=$(map_boot_status "$byte3" "$byte2" "$byte1" "$byte0")
        description="$temp"
    fi

    local sRedfishMsgId="$REDFISH_MSG_AMPERE_EVENT"
    if [[ "$description" == *"$ERROR_MSG:"* ]]; then
        sRedfishMsgId="OpenBMC.0.1.BIOSFirmwarePanicReason.Warning"
        description=${description/"$ERROR_MSG:"/""}
    fi
    # Add redfish log
    add_OEM_Action_Redfish_Log "${description}" "${sRedfishMsgId}" "${description}"
}

#format: pcie_hot_plug $tid $presentReading
function pcie_hot_plug()
{
    local tid=$1
    local description="$SOCKET_0_NAME"
    if [[ $tid -eq $SOCKET_1_TID ]]; then
        description="$SOCKET_1_NAME"
    fi
    description="$description PCIe Hot Plug:"
    local presentReading=$2
    # PresentReading value format
    # FIELD       |                   COMMENT
    # Bit 31      |   Reserved
    # Bit 30:24   |   Media slot number (0 - 63) This field can be used by UEFI
    #             |   to indicate the media slot number (such as NVMe/SSD slot)
    #             |   (7 bits)
    # Bit 23      |   Operation status: 1=operation failed
    #             |   0=operation successful
    # Bit 22      |   Action: 0 - Insertion 1 - Removal
    # Bit 21:18   |   Function (4 bits)
    # Bit 17:13   |   Device (5 bits)
    # Bit 12:5    |   Bus (8 bits)
    # Bit 4:0     |   Segment (5 bits)

    local temp=""
    temp=$(printf "Slot (%d)" $(( (presentReading >> 24) & 0x7f )))
    description="$description $temp"
    temp="Insertion"
    local action=$(( (presentReading >> 22) & 0x1 ))
    if [[ $action -eq 1 ]]; then
        temp="Removal"
    fi
    description="$description $temp"
    temp="Successful"
    local operationStatus=$(( (presentReading >> 23) & 0x1 ))
    local sRedfishMsgId="$REDFISH_MSG_AMPERE_EVENT"
    if [[ $operationStatus -eq 1 ]]; then
        temp="Failed"
        sRedfishMsgId="$REDFISH_MSG_AMPERE_WARNING"
        description="$description:$temp,"
    else
        description="$description:$temp"
    fi

    temp=$(printf "Segment (0x%02x)" $(( (presentReading) & 0x1f )))
    description="$description $temp"
    temp=$(printf "Bus (0x%02x)" $(( (presentReading >> 5) & 0xff )))
    description="$description $temp"
    temp=$(printf "Device (0x%02x)" $(( (presentReading >> 13) & 0x1f )))
    description="$description $temp"
    temp=$(printf "Function (0x%02x)" $(( (presentReading >> 18) & 0xf )))
    description="$description $temp"

    # Add redfish log
    add_OEM_Action_Redfish_Log "${description}" "${sRedfishMsgId}" "${description}"
}

#format: sensor_event_numeric_sensor_state $tid $sensorId $eventState $previousEventState $sensorDataSize $presentReading
function sensor_event_numeric_sensor_state() {
    local tid=$1
    local sensorId=$(($2))
    local eventState=$3
    local previousEventState=$4
    local sensorDataSize=$5
    local presentReading=$6

    #DIMMx_Status sensors
    if [[ $sensorId -ge 4 ]] && [[ $sensorId -le 34 ]] && [[ $((sensorId % 2)) -eq 0 ]]; then
        dimm_ddr_status "$tid" "$sensorId" "$presentReading"
        exit 0
    fi

    case $sensorId in
        $((PCIE_HOT_PLUG)) )
            pcie_hot_plug "$tid" "$presentReading"
            ;;
        $((BOOT_OVERALL)) )
            boot_overall "$tid" "$presentReading"
            ;;
        $((DDR_STATUS)) )
            dimm_ddr_status "$tid" "$sensorId" "$presentReading"
            ;;
        $((PCP_VR_STATE)) | $((SOC_VR_STATE)) | $((DPHY_VR1_STATE)) | $((DPHY_VR2_STATE))\
         | $((D2D_VR_STATE)) | $((IOC_VR1_STATE)) | $((IOC_VR2_STATE)) | $((PCI_D_VR_STATE)) | $((PCI_A_VR_STATE)))
            vrd_state "$tid" "$sensorId" "$presentReading"
            ;;
        *)
            echo "INFO: SENSOR_EVENT : NUMERIC_SENSOR_STATE: tid $tid sensorId $sensorId eventState $eventState previousEventState $previousEventState  sensorDataSize $sensorDataSize presentReading $presentReading"
            ;;
    esac
    exit 0
}

#format: sensor_event_sensor_op_state $tid $sensorId $presentOpState $previousOpState
function sensor_event_sensor_op_state() {
    local tid=$1
    local sensorId=$(($2))
    local presentOpState=$3
    local previousOpState=$4
    echo "INFO: SENSOR_EVENT : SENSOR_OP_STATE: tid $tid sensorId $sensorId presentOpState $presentOpState previousOpState $previousOpState"
}

function create_host_UE_fault_flag() {
    local tid=$(($1))
    local sensorId=$(($2))
    if [[ $SOCKET_0_TID -eq $tid ]] || [[ $SOCKET_1_TID -eq $tid ]]; then
        for id in "${UE_SENSOR_ID[@]}"; do
            if [[ $((id)) -eq $sensorId ]]; then
                busctl set-property xyz.openbmc_project.LED.GroupManager /xyz/openbmc_project/led/groups/ras_ue_fault xyz.openbmc_project.Led.Group Asserted b true
                break
            fi
        done
    fi
}

cmdLen=$(($#))
if [ $cmdLen -lt 1 ]; then
    echo "Error: Invalid command data length"
    exit 1
fi

eventType=$(($1))

case $eventType in
    $((SENSOR_EVENT)) )
        if [ $cmdLen -lt 2 ]; then
            echo "Error: SENSOR_EVENT : Invalid command data length"
            exit 1
        fi

        eventClass=$(($2))
        case $eventClass in
            $((STATE_SENSOR_STATE)) )
                #handle State sensor state event
                if [ $cmdLen -lt 7 ]; then
                    echo "Error: SENSOR_EVENT : STATE_SENSOR_STATE: Invalid command data length" 
                    exit 1
                fi
                sensor_event_state_sensor_state "$3" "$4" "$5" "$6" "$7"
                exit 0
                ;;
            $((NUMERIC_SENSOR_STATE)) )
                #handle numeric sensor state event
                if [ $cmdLen -lt 8 ]; then
                    echo "Error: SENSOR_EVENT : NUMERIC_SENSOR_STATE: Invalid command data length"
                    exit 1
                fi
                sensor_event_numeric_sensor_state "$3" "$4" "$5" "$6" "$7" "$8"
                exit 0
                ;;
            $((SENSOR_OP_STATE)) )
                #handle sensor op state event
                if [ $cmdLen -lt 6 ]; then
                    echo "Error: SENSOR_EVENT : SENSOR_OP_STATE: Invalid command data length"
                    exit 1
                fi
                sensor_event_sensor_op_state "$3" "$4" "$5" "$6"
                exit 0
                ;;
            *)
                echo "Error: SENSOR_EVENT: Invalid Sensor Event with SensorClass $eventClass"
                exit 1
                ;;
        esac
        ;;
    $((PLDM_MESSAGE_POLL_EVENT)) )
        if [ $cmdLen -lt 5 ]; then
            echo "Error: PLDM_MESSAGE_POLL_EVENT : Invalid command data length $cmdLen"
            exit 1
        fi
        tid=$2
        formatVersion=$3
        sensorId=$4
        dataTransferHandle=$5
        create_host_UE_fault_flag "$tid" "$sensorId"
        echo "INFO: PLDM_MESSAGE_POLL_EVENT: tid $tid sensorId $sensorId formatVersion $formatVersion dataTransferHandle $dataTransferHandle "
        exit 0
        ;;
    *)
        echo "Error: Unsuported EventType $eventType"
        exit 0
        ;;
esac

exit 1

