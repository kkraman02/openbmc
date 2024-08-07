FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

INSANE_SKIP:${PN} = "already-stripped"

SRC_URI:append = " \
           file://ampere_power_util.sh \
           file://ampere_firmware_upgrade.sh \
           file://ampere_flash_bios.sh \
           file://ampere_power_on_driver_binder.sh \
           file://ampere_firmware_version.sh \
           file://ampere_fanctrl.sh \
           file://ampere_scandump_mode.sh \
           file://ampere_request_mpro_state.sh \
          "

do_install:append() {
    install -d ${D}/usr/sbin
    install -m 0755 ${WORKDIR}/ampere_power_util.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_firmware_upgrade.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_flash_bios.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_power_on_driver_binder.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_firmware_version.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_fanctrl.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_scandump_mode.sh ${D}/${sbindir}/
    install -m 0755 ${WORKDIR}/ampere_request_mpro_state.sh ${D}/${sbindir}/
}
