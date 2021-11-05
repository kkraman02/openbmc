SUMMARY = "Virtual Media Service"
DESCRIPTION = "Virtual Media Service"

SRC_URI = "git://github.com/Intel-BMC/provingground.git;branch=master;protocol=https"
SRCREV = "bee56d62b209088454d166d1efae4825a2b175df"

S = "${WORKDIR}/git/virtual-media"
PV = "1.0+git${SRCPV}"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

FILESEXTRAPATHS:append_mtjade := "${THISDIR}/${PN}:"
SRC_URI += " file://0001-Fix-fail-to-Insert-and-Eject-media.patch \
             file://virtual-media.json \
           "

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.VirtualMedia.service"

DEPENDS = "udev boost nlohmann-json systemd sdbusplus"

RDEPENDS:${PN} += "nbd-client nbdkit"

inherit cmake systemd

EXTRA_OECMAKE += "-DYOCTO_DEPENDENCIES=ON"
EXTRA_OECMAKE += "-DLEGACY_MODE_ENABLED=ON"

FULL_OPTIMIZATION = "-Os -pipe -flto"

do_install:append() {
    install -m 0644 ${WORKDIR}/virtual-media.json ${D}${sysconfdir}
}