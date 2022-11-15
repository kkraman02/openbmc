FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
           file://0001-requester-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0002-responder-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0003-Add-Ampere-API-PldmMessagePollEventSignal.patch \
           file://0004-pldmtool-fix-pldmtool-stuck-in-waiting-forever-respo.patch \
           "

