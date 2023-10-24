FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " json"

SRC_URI:append = " file://events.json \
                              file://fans.json \
                              file://groups_1p.json \
                              file://groups_2p.json \
                              file://zones.json \
                              file://monitor.json \
                              file://presence.json \
                              file://phosphor-fan-control@.service \
                              file://phosphor-fan-monitor@.service \
                              file://phosphor-fan-presence-tach@.service \
"

MITCHELL_PLATFORM_NAME = "mtmitchell"

CONTROL_CONFIGS = "events.json fans.json zones.json groups_2p.json groups_1p.json"

do_install:append () {
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/phosphor-fan-monitor@.service ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/phosphor-fan-control@.service ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/phosphor-fan-presence-tach@.service ${D}${systemd_system_unitdir}

        # datadir = /usr/share
        install -d ${D}${datadir}/phosphor-fan-presence/control/${MITCHELL_PLATFORM_NAME}
        install -d ${D}${datadir}/phosphor-fan-presence/monitor/${MITCHELL_PLATFORM_NAME}
        install -d ${D}${datadir}/phosphor-fan-presence/presence/${MITCHELL_PLATFORM_NAME}

        for CONTROL_CONFIG in ${CONTROL_CONFIGS}
        do
                install -m 0644 ${WORKDIR}/${CONTROL_CONFIG} \
                        ${D}${datadir}/phosphor-fan-presence/control/${MITCHELL_PLATFORM_NAME}
        done

        install -m 0644 ${WORKDIR}/groups_2p.json \
                ${D}${datadir}/phosphor-fan-presence/control/${MITCHELL_PLATFORM_NAME}/groups.json
        install -m 0644 ${WORKDIR}/monitor.json \
                ${D}${datadir}/phosphor-fan-presence/monitor/${MITCHELL_PLATFORM_NAME}/config.json
        install -m 0644 ${WORKDIR}/presence.json \
                ${D}${datadir}/phosphor-fan-presence/presence/${MITCHELL_PLATFORM_NAME}/config.json
}
