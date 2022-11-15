FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG = "abi-development"

SRC_URI += " \
           file://0001-transport-Correct-comparison-in-while-loop-condition.patch \
           file://0002-transport-Match-type-and-command-on-response-in-pldm.patch \
           "

SRCREV = "43a7985dc9672c420f19d1bcf3248add6d3d6ba7"
