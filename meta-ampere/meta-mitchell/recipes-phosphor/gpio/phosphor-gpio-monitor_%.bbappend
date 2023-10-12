FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}-monitor += "bash"
RDEPENDS:${PN} = "bash"

SRC_URI += " \
            file://phosphor-multi-gpio-monitor.json \
            file://ampere_sys_auth_failure.sh \
           "

SYSTEMD_SERVICE:${PN}-monitor += " \
                                  ampere-host-shutdown-ack@.service \
                                  ampere-host-reboot@.service \
                                  ampere_sys_auth_failure@.service \
                                 "

FILES:${PN}-monitor += " \
                        ${datadir}/${PN}/phosphor-multi-gpio-monitor.json \
                        /usr/sbin/ampere_sys_auth_failure.sh \
                       "

do_install:append() {
    install -d ${D}${bindir}
    install -m 0644 ${WORKDIR}/phosphor-multi-gpio-monitor.json ${D}${datadir}/${PN}/

    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/ampere_sys_auth_failure.sh ${D}/${sbindir}/
}
