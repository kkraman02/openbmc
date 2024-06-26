RDEPENDS:${PN}-extras:append = " \
                                webui-vue \
                                phosphor-image-signing \
                                phosphor-virtual-sensor \
                                phosphor-misc-usb-ctrl \
                                phosphor-gpio-monitor-monitor \
                                phosphor-pid-control          \
                                phosphor-software-manager-sync \
                                mtd-utils \
                               "

RDEPENDS:${PN}-inventory:append = " \
                                   dbus-sensors \
                                   entity-manager \
                                  "

RDEPENDS:${PN}-extras:remove = " phosphor-hwmon"
VIRTUAL-RUNTIME_obmc-sensors-hwmon ?= "dbus-sensors"
RDEPENDS:${PN}-extras:append = " phosphor-virtual-sensor"
