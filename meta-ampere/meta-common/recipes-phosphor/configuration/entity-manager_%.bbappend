FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://artesyn_psu.json \
            file://liteon_psu.json \
            file://chicony_psu.json \
            file://0001-Generate-UUID-if-not-exist-in-FRU.patch \
           "

TARGET_LDFLAGS += "-luuid"

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/artesyn_psu.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/liteon_psu.json ${D}${datadir}/${PN}/configurations
     install -m 0444 ${WORKDIR}/chicony_psu.json ${D}${datadir}/${PN}/configurations
}
