FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0003-Apply-route-restrictions-by-default.patch \
            file://0004-Add-method-connect-API-to-get-system-information.patch \
            file://0005-Fix-Logout-Button-does-not-work-in-Safari.patch \
            file://0006-Temporarily-remove-Fan-Inventory-Table-from-WebUI.patch \
           "
