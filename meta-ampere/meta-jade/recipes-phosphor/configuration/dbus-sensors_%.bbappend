FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " amperecpusensor"

SRC_URI:append = " file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch \
                   file://0002-Keep-default-polling-time-when-TachSensor-returns-timeout-error.patch \
                   "
