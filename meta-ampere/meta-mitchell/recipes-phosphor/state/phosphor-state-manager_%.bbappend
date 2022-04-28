FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
                         -Dwarm-reboot=disabled \
                       "

SRC_URI:append:mtmitchell = " file://ampere-obmc-power-start@.service"

do_install:append:mtmitchell() {
    cp ${WORKDIR}/ampere-obmc-power-start@.service ${D}${systemd_system_unitdir}/obmc-power-start@.service
}
