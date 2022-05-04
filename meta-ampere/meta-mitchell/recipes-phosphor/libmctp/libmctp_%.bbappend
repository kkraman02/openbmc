FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/ampere-openbmc/libmctp;protocol=https;branch=ampere \
           file://mtmitchell_default \
           file://eid.cfg \
          "
SRCREV = "1d2f2a6a1ea40e1b34b43ee4b8760997483c80f9"

FILES:${PN} += "${datadir}/mctp/eid.cfg"

do_compile:prepend() {
    cp "${WORKDIR}/mtmitchell_default" "${WORKDIR}/default"
}

do_install:append() {
    install -d ${D}/${datadir}/mctp
    install ${WORKDIR}/eid.cfg ${D}/${datadir}/mctp/eid.cfg
}
