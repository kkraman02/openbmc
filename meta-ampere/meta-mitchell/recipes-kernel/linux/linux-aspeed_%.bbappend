FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere.cfg \
           "

SRC_URI:append:mtmitchell = " file://0001-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch"
