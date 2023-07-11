#!/bin/bash

# shellcheck disable=SC2046

FW_BOOT_OK=(
    "s0-fw-boot-ok"
    "s1-fw-boot-ok"
)

MCTP_READY=(
    "s0_mctp_ready"
    "s1_mctp_ready"
)
GET_FW_BOOT_OK=fwboot
GET_MTCP_IF=mctpinf

I2C_MCTP_BUS=3
S0_MCTP_ADDR=0x4f
S1_MCTP_ADDR=0x4e

function s0_mctp_ready()
{
    ret=1
    if i2cget -f -y "$I2C_MCTP_BUS" "$S0_MCTP_ADDR" 0; then
        ret=0
    fi
    echo $ret
}

function s1_mctp_ready()
{
    ret=1
    state=$(gpioget $(gpiofind s1-pcp-pgood))
    if [ "$state" == "1" ]; then
        if i2cget -f -y "$I2C_MCTP_BUS" "$S1_MCTP_ADDR" 0; then
            ret=0
        fi
    fi
    echo $ret
}

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <socket> <state>"
    echo "Where:"
    echo "    socket: 0 - Socket 0, 1 - Socket 1"
    echo "    state: fwboot  - Check FW_BOOT_OK assertion"
    echo "           mctpinf - Check MCTP interface ready state"
    exit 0
fi

socket=$1
arg=$2

if [[ $socket != "0" && $socket != "1" ]]
then
    echo "Invalid socket input. Exit!"
    exit 1
fi

if [[ "$arg" == "$GET_FW_BOOT_OK" ]]
then
    FW_BOOT_OK_STATE=$(gpioget $(gpiofind "${FW_BOOT_OK[$socket]}"))
    if [ "$FW_BOOT_OK_STATE" == "1" ]
    then
        echo 0
    else
        echo 1
    fi
elif [[ "$arg" == "$GET_MTCP_IF" ]]
then
    MCTP_IF_STATE=$("${MCTP_READY[$socket]}")
    echo "${MCTP_IF_STATE: -1}"
else
    echo "Invalid state input. Exit!"
    exit 1
fi
