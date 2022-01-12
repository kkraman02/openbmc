FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor"
PACKAGECONFIG:append = " nvmesensor"

SRC_URI += " \
            file://0001-amperecpu-Add-Ampere-CPU-daemon.patch \
            file://0002-amperecpu-Scan-CPU-sensors-in-the-first-power-on.patch \
            file://0003-amperecpu-Support-PresenceGpio-option.patch \
            file://0004-amperecpu-change-condition-to-re-scan-CPU-devices.patch \
            file://0005-fansensor-Add-ast2600-compatible-string.patch \
            file://0006-intrusionsensor-Add-Rearm-property.patch \
           "

PACKAGECONFIG[amperecpusensor] = "-Dampere-cpu=enabled, -Dampere-cpu=disabled"
SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'amperecpusensor', \
                                               'xyz.openbmc_project.amperecpusensor.service', \
                                               '', d)}"
