SUMMARY = "DataStax Python Driver for Apache Cassandra"
DESCRIPTION = "A modern, feature-rich and highly-tunable Python client \
library for Apache Cassandra (1.2+) and DataStax Enterprise (3.1+) using \
exclusively Cassandra's binary protocol and Cassandra Query Language v3."
HOMEPAGE = "https://github.com/datastax/python-driver"
SECTION = "devel/python"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"
SRCNAME = "cassandra-driver"

SRC_URI[sha256sum] = "0a34f9534356e5fd33af8cdda109d5e945b6335cb50399b267c46368c4e93c98"

inherit pypi setuptools3

RDEPENDS:${PN} += "\
    ${PYTHON_PN}-cython \
    ${PYTHON_PN}-geomet \
    ${PYTHON_PN}-json \
    ${PYTHON_PN}-misc \
    ${PYTHON_PN}-multiprocessing \
    ${PYTHON_PN}-numbers \
    ${PYTHON_PN}-six \
    libevent \
"

DEPENDS += "\
    ${PYTHON_PN}-cython \
"
