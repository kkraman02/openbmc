FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

LINUX_VERSION = "6.0.19"

SRC_URI = "git://github.com/ampere-openbmc/linux;protocol=https;branch=ampere"
SRC_URI += " \
            file://defconfig \
            file://mtjade.cfg \
           "

SRCREV = "30c535d706a13632c1248f1fb80d3ff11a390a8f"
