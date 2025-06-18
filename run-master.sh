#!/bin/bash

#
# Salt-Master Run Script
#

set -e

# Start sshd to listen to SSH connections from outside

mkdir -p /run/sshd
/usr/sbin/sshd

# Log Level
LOG_LEVEL=${LOG_LEVEL:-"info"}

# Run Salt as a Daemon
exec /usr/local/bin/salt-master --log-level=$LOG_LEVEL
