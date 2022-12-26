FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://firmware_update.sh \
             file://allow-reboot-actions.service \
             file://prevent-reboot-actions.service \
             file://0001-BMC-Updater-Support-update-on-BMC-Alternate-device.patch \
           "

PACKAGECONFIG[flash_bios] = "-Dhost-bios-upgrade=enabled, -Dhost-bios-upgrade=disabled"

PACKAGECONFIG:append = " flash_bios"

SYSTEMD_SERVICE:${PN}:updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'obmc-flash-host-bios@.service', '', d)}"
SYSTEMD_SERVICE:${PN}:updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'allow-reboot-actions.service', '', d)}"
SYSTEMD_SERVICE:${PN}:updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'prevent-reboot-actions.service', '', d)}"
FILES:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', '${systemd_unitdir}/system/allow-reboot-actions.service', '', d)}"
FILES:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', '${systemd_unitdir}/system/prevent-reboot-actions.service', '', d)}"

RDEPENDS:${PN} += "bash"

do_install:append() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/firmware_update.sh ${D}/usr/sbin/firmware_update.sh

    install -m 0644 ${WORKDIR}/allow-reboot-actions.service ${D}${systemd_unitdir}/system/allow-reboot-actions.service
    install -m 0644 ${WORKDIR}/prevent-reboot-actions.service ${D}${systemd_unitdir}/system/prevent-reboot-actions.service
}
