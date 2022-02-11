FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

RRECOMMENDS:${PN} += "ipmitool"

RDEPENDS:${PN} += "bash"

SRC_URI += " \
            file://0001-Correct-ipmitool-get-system-guid.patch \
            file://0002-Add-the-user_mgmt.hpp-to-Makefile.am-file-for-access.patch \
            file://0003-Change-revision-to-decimal-number.patch \
            file://0004-dbus-sdr-allow-retrieving-FRU-ID-zero.patch \
            file://0005-dbus-sdr-add-prioDbusSdrBase-for-custom-handler-priority.patch \
            file://0006-Support-chassis-bootdev-clear-cmos.patch \
            file://0007-Revert-Confirm-presence-of-NIC-devices-described-in-.patch \
            file://0008-Set-the-thresholds-value-of-the-sensors-with-some-un.patch \
            file://0009-Response-thresholds-for-Get-SDR-command.patch \
            file://0010-dbus-sdr-Reset-last-device-ID-to-0xff-when-writing-d.patch \
            file://ampere-phosphor-softpoweroff \
            file://ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service \
            "

PACKAGECONFIG[dynamic-sensors] = "--enable-dynamic-sensors"
HOSTIPMI_PROVIDER_LIBRARY += "libdynamiccmds.so"

AMPERE_SOFTPOWEROFF_TMPL = "ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service"

do_install:append(){
    install -d ${D}${includedir}/phosphor-ipmi-host
    install -m 0644 -D ${S}/selutility.hpp ${D}${includedir}/phosphor-ipmi-host
    install -m 0755 ${WORKDIR}/ampere-phosphor-softpoweroff ${D}/${bindir}/phosphor-softpoweroff
    install -m 0644 ${WORKDIR}/${AMPERE_SOFTPOWEROFF_TMPL} ${D}${systemd_unitdir}/system/xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service
}
