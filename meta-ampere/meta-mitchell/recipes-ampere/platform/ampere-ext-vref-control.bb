SUMMARY = "Ampere Computing LLC Ext Vref Control"
DESCRIPTION = "Control Ext Vref on Ampere platform"
PR = "r1"

LICENSE = "Apache-2.0"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

inherit systemd
inherit obmc-phosphor-systemd

DEPENDS = "systemd"
RDEPENDS:${PN} = "bash"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SYSTEMD_SERVICE:${PN} = "ampere-ext-vref-control.service"

SRC_URI = " \
           file://ampere_ext_vref_control.sh \
           file://ext_vref_sel_default \
          "

do_install () {
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/ampere_ext_vref_control.sh ${D}${sbindir}/
    install -d ${D}${datadir}/${PN}
    install -m 0444 ${WORKDIR}/ext_vref_sel_default ${D}${datadir}/${PN}/
}
