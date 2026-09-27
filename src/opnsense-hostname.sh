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

# Host name and domain of the installed system (shown in the web GUI as
# root@<host>.<domain>); the image ships with Indywall.internal.

TITLE="Host Name"
PHP=/usr/local/bin/php
HOSTRE='[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?'

# current values in the installed system's configuration
CURRENT=$(echo '<?php $c = simplexml_load_file("/conf/config.xml"); echo $c->system->hostname, " ", $c->system->domain;' | \
    chroot ${BSDINSTALL_CHROOT} ${PHP})
HOSTIN=${CURRENT% *}
DOMAININ=${CURRENT#* }
ANSWER=$(mktemp /tmp/hostname.XXXXXX)

while :; do
	if ! bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" --clear "${@}" \
	    --inputbox "Host name (letters, digits and hyphens):" 9 56 "${HOSTIN}" 2> ${ANSWER}; then
		rm -f ${ANSWER}
		exit 0
	fi
	HOSTIN=$(cat ${ANSWER})
	echo "${HOSTIN}" | grep -Eqx "${HOSTRE}" && break
	bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" "${@}" --ok-label "Back" \
	    --msgbox "\"${HOSTIN}\" is not a valid host name." 6 50
done

while :; do
	if ! bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" --clear "${@}" \
	    --inputbox "Domain (e.g. internal or example.com):" 9 56 "${DOMAININ}" 2> ${ANSWER}; then
		rm -f ${ANSWER}
		exit 0
	fi
	DOMAININ=$(cat ${ANSWER})
	echo "${DOMAININ}" | grep -Eqx "(${HOSTRE}\.)*${HOSTRE}" && break
	bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" "${@}" --ok-label "Back" \
	    --msgbox "\"${DOMAININ}\" is not a valid domain." 6 50
done

rm -f ${ANSWER}

# saved through the configuration class so a backup and the change history are kept
RESULT=$(chroot ${BSDINSTALL_CHROOT} ${PHP} -- "${HOSTIN}" "${DOMAININ}" 2>&1 <<'EOF'
<?php
require_once('/usr/local/opnsense/mvc/script/load_phalcon.php');
$config = OPNsense\Core\Config::getInstance();
$config->lock();
$config->object()->system->hostname = $argv[1];
$config->object()->system->domain = $argv[2];
$config->save(['description' => 'Installer: host name set']);
echo "The system is now named {$argv[1]}.{$argv[2]}.";
EOF
)

bsddialog --backtitle "OPNsense Installer" --title "${TITLE}" "${@}" \
    --msgbox "${RESULT}" 7 60
