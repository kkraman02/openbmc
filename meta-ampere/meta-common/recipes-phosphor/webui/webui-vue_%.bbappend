FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0002-UserManagement-fix-incorrect-max-failed-login-attemp.patch \
            file://0003-Added-route-restrictions-based-on-user-privilege.patch \
            file://0004-Apply-route-restrictions-by-default.patch \
           "
