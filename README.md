# procServ Configuration Environment

`procServ` application for Linux Configuration Environment.

## About

This repository helps to build the `procServ` package and its customized application consistently on Linux.

* The source codes are located in <https://github.com/ralphlange/procServ/>
* Tested on Debian 12, Debian 13, Debian 14, Rocky Linux 8, Rocky Linux 9, and Rocky Linux 10 (see `.github/workflows/`).

## Prerequisites

Debian and its variants:

```bash
apt install make gcc g++ autoconf autotools-dev libtool git
```

## commands

By default, everything will be within `/usr/local` path. It can be customized via

```bash
echo "INSTALL_LOCATION=where...." > configure/CONFIG_SITE.local
```

* Build

```bash
make init
make conf
make build
make install
```


* Others

```bash
make uninstall
make clean
make distclean
```
