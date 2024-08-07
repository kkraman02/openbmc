SUMMARY = "plocate, a much faster locate"
HOMEPAGE = "https://plocate.sesse.net/"
DESCRIPTION = "plocate is a locate(1) based on posting lists, completely replacing mlocate with a much faster (and smaller) index. It is suitable as a default locate on your system."
SECTION = "base"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

inherit meson pkgconfig

DEPENDS = "zstd liburing"

SRC_URI = "https://plocate.sesse.net/download/${BP}.tar.gz"

SRC_URI[sha256sum] = "9b3d2842a08e69633c0ffa480c139603514ce59f1d021c263e9301324976959f"
