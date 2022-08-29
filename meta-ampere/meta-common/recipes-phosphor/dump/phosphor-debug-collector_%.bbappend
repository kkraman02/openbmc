FILESEXTRAPATHS:prepend := "${THISDIR}/phosphor-debug-collector:"

SRC_URI += " \
            file://0001-Add-CPER-Log-and-Crashdump-support-in-FaultLog.patch \
            file://0002-Support-maximum-theshold-for-each-type-of-faultlog.patch \
            file://0003-Support-BERT-and-Diagnostic-type.patch \
            file://0004-Support-restore-FaultLog-entries-after-service-resta.patch \
           "

SRCREV = "05ef81639c1fb7fc2fc78b29ca7e7486a86ddfb2"

EXTRA_OEMESON = " \
        -DMAX_TOTAL_FAULT_LOG_ENTRIES=100 \
        -DMAX_TOTAL_CPER_LOG_ENTRIES=10 \
        -DMAX_TOTAL_BERT_ENTRIES=2 \
        -DMAX_TOTAL_DIAGNOSTIC_ENTRIES=8 \
        -Ddump_rotate_config=enabled \
        "
