FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/ampere-openbmc/libmctp;protocol=https;branch=ampere \
           file://mtmitchell_default \
           file://eid.cfg \
          "
SRCREV = "c00520c4e56c04176355e1c17216a15775ebdccb"

FILES:${PN} += "${datadir}/mctp/eid.cfg"

do_compile:prepend() {
    cp "${WORKDIR}/mtmitchell_default" "${WORKDIR}/default"
}

do_install:append() {
    install -d ${D}/${datadir}/mctp
    install ${WORKDIR}/eid.cfg ${D}/${datadir}/mctp/eid.cfg
}
