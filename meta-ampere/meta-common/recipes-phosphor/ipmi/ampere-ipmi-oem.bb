SUMMARY = "Ampere OEM IPMI commands"
DESCRIPTION = "Ampere OEM IPMI commands"

LICENSE = "Apache-2.0"
S = "${WORKDIR}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=a6a4edad4aed50f39a66d098d74b265b"

DEPENDS = "boost phosphor-ipmi-host phosphor-logging systemd"

inherit meson pkgconfig obmc-phosphor-ipmiprovider-symlink

LIBRARY_NAMES = "libzampoemcmds.so"

S = "${WORKDIR}/git"
SRC_URI = "git://github.com/ampere-openbmc/ampere-ipmi-oem;protocol=https;branch=ampere"
SRCREV = "36d95deeb035377fb9cdd7a7a9b9dd4f9a7dc4c4"

HOSTIPMI_PROVIDER_LIBRARY += "${LIBRARY_NAMES}"
NETIPMI_PROVIDER_LIBRARY += "${LIBRARY_NAMES}"

FILES:${PN}:append = " ${libdir}/ipmid-providers/lib*${SOLIBS}"
FILES:${PN}:append = " ${libdir}/host-ipmid/lib*${SOLIBS}"
FILES:${PN}:append = " ${libdir}/net-ipmid/lib*${SOLIBS}"
FILES:${PN}-dev:append = " ${libdir}/ipmid-providers/lib*${SOLIBSDEV}"

do_install:append(){
   install -d ${D}${includedir}/ampere-ipmi-oem
   install -m 0644 -D ${S}/include/*.hpp ${D}${includedir}/ampere-ipmi-oem
}
