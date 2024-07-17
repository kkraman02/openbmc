FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG[dynamic-storages-only] = "-Ddynamic-storages-only=enabled, -Ddynamic-storages-only=disabled"

RRECOMMENDS:${PN} += "ipmitool"
RDEPENDS:${PN} += "bash"

SRC_URI += "\
            file://0001-Allow-user-access-from-external-repos.patch \
            file://0002-Response-thresholds-for-Get-SDR-command.patch \
            file://0003-dbus-sdr-support-static-FRU-s-ID-configuration.patch \
            file://0004-Change-method-for-NMI-triggering.patch \
            file://0005-dcmi-Support-fully-power-limit-setting-commands.patch \
            file://0006-dbus-sdr-sel-support-getting-sensor-number-from-stat.patch \
            file://0007-dcmi-correct-return-data-of-Get-Configuration-Parame.patch \
            file://0008-chassishandler-Interpret-Transitioning-state-in-getP.patch \
            file://ampere-phosphor-softpoweroff \
            file://ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service \
           "

AMPERE_SOFTPOWEROFF_TMPL = "ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service"

do_install:append(){
    install -d ${D}${includedir}/phosphor-ipmi-host
    install -m 0644 -D ${S}/selutility.hpp ${D}${includedir}/phosphor-ipmi-host
    install -m 0755 ${WORKDIR}/ampere-phosphor-softpoweroff ${D}/${bindir}/phosphor-softpoweroff
    install -m 0644 ${WORKDIR}/${AMPERE_SOFTPOWEROFF_TMPL} ${D}${systemd_unitdir}/system/xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service
}
