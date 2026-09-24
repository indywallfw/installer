#!/bin/sh
#-
# Copyright (c) 2026 Indywall
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

# Ask for MaxMind GeoLite2 credentials (Indywall country blocking) and
# store them in the installed system. There is no network during the
# install, so the database itself is downloaded at first boot by the
# Indywall plugin's boot check.

SETUP=/usr/local/opnsense/scripts/indywall/geoip_setup.php
TITLE="GeoIP Database"

if [ ! -x "${BSDINSTALL_CHROOT}${SETUP}" ]; then
	bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" "${@}" \
	    --msgbox "The Indywall plugin is not part of this image." 5 50
	exit 0
fi

ACCOUNT=$(mktemp /tmp/geoip.XXXXXX)
KEY=$(mktemp /tmp/geoip.XXXXXX)
ACCOUNTIN=
KEYIN=

while [ -z "${ACCOUNTIN}" ]; do
	if ! bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" --clear "${@}" \
	    --inputbox "Country blocking uses the free MaxMind GeoLite2\ndatabase (sign up at maxmind.com).\n\nMaxMind account ID:" 12 56 2> ${ACCOUNT}; then
		rm -f ${ACCOUNT} ${KEY}
		exit 0
	fi
	ACCOUNTIN=$(cat ${ACCOUNT})
done

while [ -z "${KEYIN}" ]; do
	if ! bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" --clear --insecure "${@}" \
	    --passwordbox "MaxMind license key\n(Account > Manage License Keys):" 9 56 2> ${KEY}; then
		rm -f ${ACCOUNT} ${KEY}
		exit 0
	fi
	KEYIN=$(cat ${KEY})
done

# the key goes through stdin, never onto a command line
RESULT=$( (cat ${KEY}; echo) | chroot ${BSDINSTALL_CHROOT} ${SETUP} \
    --account "${ACCOUNTIN}" --key-stdin --no-download 2>&1)

rm -f ${ACCOUNT} ${KEY}

bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" "${@}" \
    --msgbox "${RESULT}" 8 60
