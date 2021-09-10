SUMMARY = "Phosphor OpenBMC SSIF to DBUS"
DESCRIPTION = "Phosphor OpenBMC SSIF to DBUS."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS += "systemd"
DEPENDS += "phosphor-logging"
DEPENDS += "sdbusplus"
DEPENDS += "cli11"
PROVIDES += "virtual/obmc-host-ipmi-hw"
SRCREV = "d2a2d41af375b88f9cb4e69cd8c5b1ea9763eb91"
PV = "1.0+git${SRCPV}"
PR = "r1"

SRC_URI = "git://git@gitlab.com/AmpereComputing/bmc/openbmc/ssifbridge.git;protocol=ssh;branch=ampere"

SYSTEMD_SERVICE:${PN} = "ssifbridge.service"
S = "${WORKDIR}/git"

inherit meson pkgconfig
inherit systemd

RRECOMMENDS:${PN} += "phosphor-ipmi-host"

RPROVIDES:${PN} += "virtual-obmc-host-ipmi-hw"
