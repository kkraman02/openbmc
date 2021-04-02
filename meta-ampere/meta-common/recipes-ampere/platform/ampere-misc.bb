SUMMARY = "Ampere misc"
DESCRIPTION = "The Ampere's applications to handle platform behavior"
HOMEPAGE = "https://github.com/ampere-openbmc/ampere-misc"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=792dd876844979c80e1a4f859bc2a1e5"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

inherit meson pkgconfig
inherit systemd

DEPENDS += "sdbusplus"
DEPENDS += "phosphor-dbus-interfaces"
DEPENDS += "phosphor-logging"
DEPENDS += "systemd"
DEPENDS += "boost"
DEPENDS += "gpioplus"
DEPENDS += "sdeventplus"
DEPENDS += "libgpiod"
DEPENDS += "nlohmann-json"
DEPENDS += "i2c-tools"

RDEPENDS:${PN} += "bash"

SRC_URI = "git://github.com/ampere-openbmc/ampere-misc.git;protocol=https;branch=ampere"
SRCREV = "f67b6e90fa6507403581e1dee249d6002c5b8f77"

S = "${WORKDIR}/git"

PACKAGECONFIG = " state-logger ampere-cpld-fwupdate power-manager"
PACKAGECONFIG[nmi-manager] = "-Dnmi-manager=enabled, -Dnmi-manager=disabled"
PACKAGECONFIG[ampere-cpld-fwupdate] = "-Dampere-cpld-fwupdate=enabled, -Dampere-cpld-fwupdate=disabled"
PACKAGECONFIG[state-logger] = "-Dstate-logger=enabled, -Dstate-logger=disabled"
PACKAGECONFIG[power-manager] = "-Dpower-manager=enabled, -Dpower-manager=disabled"
PACKAGECONFIG[crash-capture-manager] = "-Dcrash-capture-manager=enabled, -Dcrash-capture-manager=disabled"
PACKAGECONFIG[ampere-cpu-present] = "-Dampere-cpu-present=enabled, -Dampere-cpu-present=disabled"

SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "nmi-manager", "xyz.openbmc_project.nmi.manager.service nmi.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "state-logger", "xyz.openbmc_project.state_logger.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "power-manager", " xyz.openbmc_project.power.manager.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "power-manager", " power-cap-action-oem.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "power-manager", " power-cap-exceeds-limit.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "power-manager", " power-cap-drops-below-limit.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "crash-capture-manager", "com.ampere.crashcapture.manager.service", "", d)}"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "ampere-cpu-present", " xyz.openbmc_project.Ampere.CpuPresent.service", "", d)}"

FILES:${PN} += "${@bb.utils.contains("PACKAGECONFIG", "power-manager"," ${datadir}/power-manager/power-manager-cfg.json", "", d)}"
