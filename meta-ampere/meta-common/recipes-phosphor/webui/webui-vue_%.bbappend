FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0002-Fix-User-Management-Page-issues-title-and-Policy.patch \
            file://0003-Added-route-restrictions-based-on-user-privilege.patch \
            file://0004-Apply-route-restrictions-by-default.patch \
            file://0005-Fix-wrong-firmware-update-URL.patch \
           "
