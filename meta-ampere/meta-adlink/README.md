OpenBMC Port to ADLINK COM-HPC-ALT Systems
==========================================

This subtree contains the port of OpenBMC to ADLINK COM-HPC-ALT Ampere
Altra based systems. These include:

- Ampere Altra Dev Kit
- Ampere Altra Developer Platform
- AVA Developer Platform

Known Issues
------------
- SMPro (SoC/Core/DIMM) sensors occasionally return bogus results, for
  example temperature readings of 127 degC or 511 degC. This appears to
  happen when the host is rebooted.
- SOL in the webui doesn't work; neither do the ssh SOL consoles.
- Fan detection isn't working - missing fans are shown as having a high rpm.

Flash Sizes
-----------

If you have a 32MB (256Mb), 64MB (512Mb) or 128MB (1Gb) EEPROM, you can
build firmware images for them by setting `FLASH_SIZE`:

After running `. setup comhpcalt` edit conf/local.conf (i.e.
build/comhpcalt/conf/local.conf) and comment/uncomment the `FLASH_SIZE`
lines as needed.

Building
--------

Run the following to build a firmware image:

```
. setup comhpcalt
bitbake obmc-phosphor-image
```

If you're building on a system with a relatively large number of cores compared to memory (such as 8 cores and 32GB RAM)
you'll probably want to reduce the default parallelism during the build to avoid running out of memory.

Do this by adding the following to conf/local.conf after running `. setup comhpcalt` e.g.:
```
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j 2"
```
