FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
EXTRA_OENPM = "-- --mode ampere"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0002-Update-Server-status-in-Server-power-operations-page.patch \
            file://0004-Display-Power-Supply-Inventory-from-PowerSubsystem.patch \
            file://0005-add-Ampere-env.patch \
            file://0006-Add-timeout-when-setting-NTP-mode.patch \
            file://0007-Change-to-display-1000-last-event-logs.patch \
           "
