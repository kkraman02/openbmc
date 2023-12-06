FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
                file://xyz.openbmc_project.led.controller@.service \
            "

do_install::append() {
    install -m 0644 ${WORKDIR}/xyz.openbmc_project.led.controller@.service \
            ${D}${systemd_unitdir}/system/xyz.openbmc_project.led.controller@.service
}
