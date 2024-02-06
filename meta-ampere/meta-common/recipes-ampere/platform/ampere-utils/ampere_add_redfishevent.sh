#!/bin/bash

registry=$1
msgarg=$2

if [ -z "$registry" ]; then
	echo "Usage:"
	echo "     $0 <redfish registry> <argument>"
	exit
fi

# Check if logger exist. Do nothing if not exists
if ! command -v logger;
then
	echo "logger does not exist. Skip log events for $registry $msgarg"
	exit
fi

# Log events
logger --journald << EOF
MESSAGE=
PRIORITY=
SEVERITY=
REDFISH_MESSAGE_ID=$registry
REDFISH_MESSAGE_ARGS=$msgarg
EOF
