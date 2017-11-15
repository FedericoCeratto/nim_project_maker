#!/bin/sh

set -e

if [ "$1" = "configure" ]; then
    if ! getent passwd ##binname## >/dev/null; then
        adduser --quiet --system --group --home /var/lib/##binname## ##binname##
    fi
fi

#DEBHELPER#

exit 0
