FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON += " -Ddata_com_ampere=true"

SRC_URI:append = " file://0001-meta-ampere-pldm-add-the-dbus-interface-for-PldmMess.patch \
                   file://0002-Add-d-bus-OEM-for-boot-progress.patch \
                   file://0003-Add-Numeric-Sensor-Event-signals.patch \
                   file://0004-Add-HostInterface-D-bus.patch \
                   file://0005-Add-Ampere-Crash-Capture-manager-interface.patch \
                 "
