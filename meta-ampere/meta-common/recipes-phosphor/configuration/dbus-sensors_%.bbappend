FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-amperecpu-Add-Ampere-CPU-daemon.patch \
            file://0002-amperecpu-Scan-CPU-sensors-in-the-first-power-on.patch \
            file://0003-amperecpu-Support-PresenceGpio-option.patch \
            file://0004-adcsensor-Disable-io_uring-build.patch \
            file://0005-chassisintrusionsensor-hwmon-adding.patch \
            file://0006-chassisintrusionsensor-add-ReArm-property.patch \
            file://0007-amperecpu-Fix-all-S1-sensors-are-disable.patch \
            file://0008-fansensor-Add-ast2600-compatible-string.patch \
           "

PACKAGECONFIG[amperecpusensor] = "-Dampere-cpu=enabled, -Dampere-cpu=disabled"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'amperecpusensor', \
                                               'xyz.openbmc_project.amperecpusensor.service', \
                                               '', d)}"
