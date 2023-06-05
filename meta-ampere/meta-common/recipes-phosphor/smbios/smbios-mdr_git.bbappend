FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " smbios-ipmi-blob"

PACKAGECONFIG:remove = " cpuinfo"

SRC_URI += " \
            file://0001-Correct-install-directory-for-service-files.patch \
           "
