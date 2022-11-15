FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
           file://0001-Correct-the-compact-numeric-sensor-pdr-struct-name.patch \
           file://0002-Add-day-week-month-year-occurrence-rate.patch \
           file://0003-requester-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0004-responder-Add-encode-decode-for-PollForPlatformEvent.patch \
           file://0005-Add-Ampere-API-PldmMessagePollEventSignal.patch \
           file://0006-pldmtool-fix-pldmtool-stuck-in-waiting-forever-respo.patch \
           "

