FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0008-ADC-Match-InterfaceAdded-signal.patch \
            file://0009-ADCSensor-Get-CPU-Present-when-creating-sensors.patch \
           "
