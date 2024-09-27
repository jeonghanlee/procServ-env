# procServ Configuration Environment

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
