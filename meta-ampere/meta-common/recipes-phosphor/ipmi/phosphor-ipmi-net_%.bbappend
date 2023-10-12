FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Handle-SOL-payload-deactivation-for-stale-session.patch \
           "
