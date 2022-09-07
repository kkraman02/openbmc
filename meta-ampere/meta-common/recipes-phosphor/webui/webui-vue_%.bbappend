FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
EXTRA_OENPM = "-- --mode ampere"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0002-Update-Server-status-in-Server-power-operations-page.patch \
            file://0003-Fix-pressing-Refresh-button-not-removing-deleted-sen.patch \
            file://0004-Display-Power-Supply-Inventory-from-PowerSubsystem.patch \
            file://0005-add-Ampere-env.patch \
           "
