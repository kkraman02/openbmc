FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/ampere-openbmc/libmctp;protocol=https;branch=ampere \
           file://mtmitchell_default \
           file://eid.cfg \
          "
SRCREV = "c283b05a4f293104cb267186cd42e94927c3ed47"

FILES:${PN} += "${datadir}/mctp/eid.cfg"

do_compile:prepend() {
    cp "${WORKDIR}/mtmitchell_default" "${WORKDIR}/default"
}

do_install:append() {
    install -d ${D}/${datadir}/mctp
    install ${WORKDIR}/eid.cfg ${D}/${datadir}/mctp/eid.cfg
}
