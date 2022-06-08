FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " amperecpusensor"

SRC_URI:append = " file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch \
                   "
