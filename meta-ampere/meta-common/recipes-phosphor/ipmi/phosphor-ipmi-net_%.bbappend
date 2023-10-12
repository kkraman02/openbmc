FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Revert-Optimize-SOL-logic-according-to-SOL-Configura.patch \
            file://0002-Handle-SOL-payload-deactivation-for-stale-session.patch \
           "
