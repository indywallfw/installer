# Testing the Indywall installer

Every pull request runs `make test` on FreeBSD 15.1 (GitHub Actions,
`.github/workflows/tests.yml`); the **tests / unit** check must pass before
merging. New code and bug fixes come with tests; a fix comes with a test that
fails without it.

## Running the tests

```sh
make test                          # fails on any failure, prints the report
cd tests && kyua test hostname_test && kyua report --verbose
```

Kyua and ATF are part of the FreeBSD base system; nothing to install. The
tests do not need root and never touch disks.

## Where tests live

`tests/`, one ATF (`atf-sh`) program per installer step, listed in
`tests/Kyuafile`:

| Script | Tests |
|--------|-------|
| `src/opnsense-hostname.sh` | `tests/hostname_test` |
| `src/opnsense-rootpass.sh` | `tests/rootpass_test` |
| `src/opnsense-license.sh`, `src/opnsense-geoip.sh` | `tests/license_test` |
| `src/opnsense.subr.sh` | `tests/subr_test` |

- `tests/stubs.subr` replaces `bsddialog` (queued answers; every call is
  logged so tests can check prompts and prefilled values), `chroot`,
  `sysctl` and the installed system's programs.
- The disk steps (install, ufs, zfs, import, reset) are not unit tested.
