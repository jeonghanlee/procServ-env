# procServ Configuration Environment
[![Debian 12](https://github.com/jeonghanlee/procServ-env/actions/workflows/debian12.yml/badge.svg)](https://github.com/jeonghanlee/procServ-env/actions/workflows/debian12.yml)
[![Rocky8](https://github.com/jeonghanlee/procServ-env/actions/workflows/rocky8.yml/badge.svg)](https://github.com/jeonghanlee/procServ-env/actions/workflows/rocky8.yml)
[![Rocky9](https://github.com/jeonghanlee/procServ-env/actions/workflows/rocky9.yml/badge.svg)](https://github.com/jeonghanlee/procServ-env/actions/workflows/rocky9.yml)

`procServ` application for Linux Configuration Environment.


* The source codes are located in <https://github.com/ralphlange/procServ/>
* Required packages (Debian and its variants) as follows

```bash
apt install autoconf
```

## About
This repository helps to build the `procServ` package and its customized application consistently on Linux.

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
