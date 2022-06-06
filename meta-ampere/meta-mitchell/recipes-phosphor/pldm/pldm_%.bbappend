FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
             file://dbus_to_host_effecter.json \
             file://eid_to_name.json \
           "

EXTRA_OEMESON += " \
                -Dsleep-between-get-sensor-reading=10 \
                -Dpoll-sensor-timer-interval=3000 \
                "

do_install:append() {
    install -d ${D}/${datadir}/pldm
    install ${WORKDIR}/eid_to_name.json ${D}/${datadir}/pldm/
    install ${WORKDIR}/dbus_to_host_effecter.json ${D}/${datadir}/pldm/host/
}
