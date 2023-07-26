FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://arch/arm/dts \
            file://0001-mtd-spi-spi-nor-core-Check-the-4byte-opcode-supporti.patch \
            file://0002-cmd-fru-Add-support-for-FRU-commands.patch \
           "

do_configure:append (){
    cp -rf "${WORKDIR}/arch/arm/dts/" "${S}/arch/arm/"
}

