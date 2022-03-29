FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON += " -Ddata_com_ampere=true"

SRC_URI:append = " file://0001-pldm-add-PldmMessagePollEvent-and-NumericSensorEvent.patch \
                   file://0002-Add-d-bus-OEM-for-boot-progress.patch \
                   file://0003-Add-HostInterface-dbus.patch \
                   file://0004-Add-Ampere-Crash-Capture-manager-interface.patch \
                 "
