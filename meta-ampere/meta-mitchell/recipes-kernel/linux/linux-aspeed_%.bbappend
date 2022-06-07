FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://ampere.cfg \
            file://0001-mtd-spi-nor-aspeed-Force-using-4KB-sector-size-for-p.patch \
           "
SRC_URI:append:mtmitchell = " file://0002-mtd-spi-nor-aspeed-force-exit-4byte-mode-when-unbind.patch"
