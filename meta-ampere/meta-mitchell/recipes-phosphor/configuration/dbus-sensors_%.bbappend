FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://xyz.openbmc_project.adcsensor-override.conf"

FILES:${PN} += "${systemd_system_unitdir}/xyz.openbmc_project.adcsensor.service.d"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}/xyz.openbmc_project.adcsensor.service.d
    install -m 644 ${WORKDIR}/xyz.openbmc_project.adcsensor-override.conf \
        ${D}${systemd_system_unitdir}/xyz.openbmc_project.adcsensor.service.d
}