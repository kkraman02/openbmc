SUMMARY = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=599d2d1ee7fc84c0467b3d19801db870"
DEPENDS = "libusb-compat libftdi"
RDEPENDS:${PN} = "libusb1"

#Remote Git Repository
SRC_URI = "git://github.com/AmpereComputing/ampere-openocd.git;protocol=https;branch=release/3.5.2.1"
SRCREV = "17b9b26d771f45f1026cb10e0ae233976dc31620"
S = "${WORKDIR}/git"

inherit pkgconfig autotools-brokensep gettext

BBCLASSEXTEND += "native nativesdk"

EXTRA_OECONF = "--disable-doxygen-html"

do_configure[network] = "1"

do_configure() {
    ./bootstrap
    install -m 0755 ${STAGING_DATADIR_NATIVE}/gnu-config/config.guess ${S}/jimtcl/autosetup
    install -m 0755 ${STAGING_DATADIR_NATIVE}/gnu-config/config.sub ${S}/jimtcl/autosetup
    oe_runconf ${EXTRA_OECONF}
}

do_install() {
    oe_runmake DESTDIR=${D} install
    if [ -e "${D}${infodir}" ]; then
      rm -Rf ${D}${infodir}
    fi
    if [ -e "${D}${mandir}" ]; then
      rm -Rf ${D}${mandir}
    fi
    if [ -e "${D}${bindir}/.debug" ]; then
      rm -Rf ${D}${bindir}/.debug
    fi
}

FILES:${PN} = " \
  ${datadir}/openocd/* \
  ${bindir}/openocd \
  "

PACKAGECONFIG[sysfsgpio] = "--enable-sysfsgpio,--disable-sysfsgpio"
PACKAGECONFIG[remote-bitbang] = "--enable-remote-bitbang,--disable-remote-bitbang"
PACKAGECONFIG ??= "sysfsgpio remote-bitbang"
