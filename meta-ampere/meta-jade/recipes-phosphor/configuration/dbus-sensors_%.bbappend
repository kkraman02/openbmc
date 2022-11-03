FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " amperecpusensor"

SRC_URI:append = " file://0001-Keep-default-polling-time-when-TachSensor-returns-timeout-error.patch \
                   "
