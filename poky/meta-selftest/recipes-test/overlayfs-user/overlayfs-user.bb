SUMMARY = "Overlayfs class unit test"
DESCRIPTION = "Contains an overlayfs configuration"
LICENSE = "MIT"

INHIBIT_DEFAULT_DEPS = "1"
EXCLUDE_FROM_WORLD = "1"

inherit_defer ${@bb.utils.contains("DISTRO_FEATURES", "overlayfs", "overlayfs", "", d)}
include test_recipe.inc

OVERLAYFS_WRITABLE_PATHS[mnt-overlay] += "/usr/share/my-application"

do_install() {
    install -d ${D}/usr/share/my-application
    install -d ${D}${sysconfdir}
    echo "Original file in /etc" >> ${D}${sysconfdir}/lower-layer-test.txt
}

FILES:${PN} += "\
    ${exec_prefix} \
    ${sysconfdir \
"
