FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LINUX_VERSION = "6.0.19"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://ampere.cfg \
           "

SRCREV = "4a57db8b233658b11d5f97492a197f10107d643d"
