FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
           file://0001-transport-Prevent-sticking-in-waiting-for-response.patch \
           file://0002-Verify-the-response-message-in-pldm_transport_send_r.patch \
           "

