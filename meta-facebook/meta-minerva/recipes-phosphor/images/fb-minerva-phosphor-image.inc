# Minerva Image configuration

# Monitor the GPIO on the system and take action.
OBMC_IMAGE_EXTRA_INSTALL:append = " \
    phosphor-gpio-monitor \
"
