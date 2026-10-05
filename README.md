Indywall installer
==================

The installer for the Indywall firewall: a scriptable replacement for
bsdinstaller, based on bsdinstall, that uses the cpdup utility to clone
the running live system onto the target disk.

The scripts plug into the base system's bsdinstall directory and adjust
its workflow and branding for Indywall. Every dialog is titled "Indywall
Installer".

Final configuration
-------------------

After the system is copied, the Final Configuration menu offers:

- **Root Password**: set the password of the system management account.
- **Host Name**: name the system (default `Indywall.internal`), shown in
  the web GUI as `root@<host>.<domain>` (`opnsense-hostname.sh`).
- **GeoIP Database**: enter a MaxMind GeoLite2 account ID and license key
  for country blocking (`opnsense-geoip.sh`). The Indywall plugin then
  downloads the database at first boot and keeps it current daily.
- **License Key**: enter the customer's Indywall license key
  (`opnsense-license.sh`). It is stored in the installed system; the
  Indywall plugin activates it with the license server as soon as the
  system is online at first boot. It can also be entered later on the
  Indywall: License page.
- **Complete Install**: confirm and exit.

The scripts keep their `opnsense-*` file names so the rest of the system
(core's `opnsense-installer` launcher, bsdinstall) finds them unchanged.

How the image uses this repository
----------------------------------

The Indywall image installs this code as the `opnsense-installer` package,
built by the `opnsense/installer` port in
[indywallfw/ports](https://github.com/indywallfw/ports). The port pins a
commit of this repository (`GH_TAGNAME`), so a change here reaches the
image only after the port is updated:

1. Merge the change into `master` here.
2. In the ports repository, set `GH_TAGNAME` in `opnsense/installer/Makefile`
   to the new commit and regenerate `distinfo` (`make makesum`).
3. When a script is added or removed, update `opnsense/installer/pkg-plist`
   as well; files missing from it are silently left out of the package.

A new script also needs an entry in `src/Makefile` (`SCRIPTS`).

Origin
------

Indywall is built on [OPNsense](https://opnsense.org). This repository is a
fork of [opnsense/installer](https://github.com/opnsense/installer) and
remains available under the BSD 2-clause license in `LICENSE`.
