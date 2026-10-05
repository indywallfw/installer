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

# Ask for the customer's Indywall license key and store it in the installed
# system. There is no network during the install: the Indywall plugin
# activates the key with the license server at first boot
# (rc.syshook.d/start/60-indywall-license). It can also be entered later on
# the Indywall: License page.

SETUP=/usr/local/opnsense/scripts/indywall/license_setup.php
TITLE="License Key"

if [ ! -x "${BSDINSTALL_CHROOT}${SETUP}" ]; then
	bsddialog --backtitle "Indywall Installer" --title "${TITLE}" "${@}" \
	    --msgbox "This image has no Indywall licensing." 5 50
	exit 0
fi

ANSWER=$(mktemp /tmp/license.XXXXXX)
KEYIN=

while :; do
	if ! bsddialog --backtitle "Indywall Installer" --title "${TITLE}" --clear "${@}" \
	    --inputbox "Indywall license key, as you received it\n(IW-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX).\n\nIt is activated when this system first goes online." \
	    12 60 "${KEYIN}" 2> ${ANSWER}; then
		rm -f ${ANSWER}
		exit 0
	fi
	KEYIN=$(cat ${ANSWER})
	# the key goes through stdin, never onto a command line
	if RESULT=$(printf '%s\n' "${KEYIN}" | chroot ${BSDINSTALL_CHROOT} ${SETUP} --key-stdin 2>&1); then
		break
	fi
	bsddialog --backtitle "Indywall Installer" --title "${TITLE}" "${@}" --ok-label "Back" \
	    --msgbox "${RESULT}" 7 60
done

rm -f ${ANSWER}

bsddialog --backtitle "Indywall Installer" --title "${TITLE}" "${@}" \
    --msgbox "${RESULT}" 9 60
