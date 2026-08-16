# Changelog

All notable changes to this project are documented in this file.

## 1.0.0 — Foundation Release

First tagged release of the `procServ` configuration environment.

### Features

- Modular Makefile environment driving the upstream `procServ` source
  tree through `init`, `conf`, `build`, `install`, `uninstall`, `clean`,
  and `distclean`.
- Installation root selectable with `INSTALL_LOCATION` in
  `configure/CONFIG_SITE.local`, defaulting to `/usr/local`.
- Annotated targets in `make help` and a build-tool precheck that gates
  `make init`.
- CI workflows for Debian 12, Debian 13, Debian 14, Rocky Linux 8,
  Rocky Linux 9, and Rocky Linux 10.

### Fixes

- `src_install` follows the configured `SUDO` value instead of invoking
  `sudo` unconditionally, so a writable destination installs without
  privilege escalation (#1).
- Privilege detection resolves the nearest existing path, so an absent
  destination below a writable parent selects an empty `SUDO` value
  while a protected parent still selects `sudo`.
