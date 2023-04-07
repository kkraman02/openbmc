FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/mctp-ctrl:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/nmi-manager:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/power-manager:"

PACKAGECONFIG += " mctp-ctrl nmi-manager"
PACKAGECONFIG[mctp-ctrl] = "-Dmctp-ctrl=enabled -Dmctp-delay-before-add-terminus=1000 \
                            -Dmctp-delay-before-add-second-terminus=0 \
                            -Dmctp-checking-s1-ready-time-out=20000, \
                            -Dmctp-ctrl=disabled"

SRC_URI += " \
             file://ampere_slave_present.sh \
             file://ampere_s1_ready.sh \
             file://dbus_utils.sh \
             file://power_cap_dbus_utils.sh \
             file://power_cap_exceed_limit.sh \
             file://power_cap_drop_below_limit.sh \
             file://nmi.service \
             file://power-cap-drops-below-limit.service \
             file://power-cap-exceeds-limit.service \
           "

do_install:append () {
    install -d ${D}/${sbindir}

    install -m 0755 ${WORKDIR}/ampere_slave_present.sh ${D}/${sbindir}/ampere_slave_present.sh
    install -m 0755 ${WORKDIR}/ampere_s1_ready.sh ${D}/${sbindir}/ampere_s1_ready.sh
    install -m 0755 ${WORKDIR}/dbus_utils.sh ${D}/${sbindir}/dbus_utils.sh
    install -m 0755 ${WORKDIR}/power_cap_dbus_utils.sh ${D}/${sbindir}/power_cap_dbus_utils.sh
    install -m 0755 ${WORKDIR}/power_cap_exceed_limit.sh ${D}/${sbindir}/power_cap_exceed_limit.sh
    install -m 0755 ${WORKDIR}/power_cap_drop_below_limit.sh ${D}/${sbindir}/power_cap_drop_below_limit.sh

    install -m 0644 ${WORKDIR}/nmi.service ${D}${systemd_unitdir}/system/nmi.service
    install -m 0644 ${WORKDIR}/power-cap-drops-below-limit.service \
                    ${D}${systemd_unitdir}/system/power-cap-drops-below-limit.service
    install -m 0644 ${WORKDIR}/power-cap-exceeds-limit.service \
                    ${D}${systemd_unitdir}/system/power-cap-exceeds-limit.service
}
