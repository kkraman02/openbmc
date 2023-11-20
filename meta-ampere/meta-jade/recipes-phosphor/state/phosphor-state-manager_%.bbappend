FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = "no-warm-reboot"

SRC_URI += " \
	      file://0001-Limit-power-actions-when-the-host-is-off.patch \
	   "

