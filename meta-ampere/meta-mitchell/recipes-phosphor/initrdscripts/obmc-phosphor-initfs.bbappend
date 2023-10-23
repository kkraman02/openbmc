FILESEXTRAPATHS:append :="${THISDIR}/${PN}:"

SRC_URI += " \
             file://ampere-whitelist \
             file://0001-initrdscripts-Support-save-files-in-BMC-fw-update.patch \
           "

do_install:append() {
        install -m 0755 ${WORKDIR}/ampere-whitelist ${D}/whitelist
}

