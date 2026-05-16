#!/usr/bin/env bash
# Verify required build tools are available before make init clones the source.

set -euo pipefail

required=(git make gcc g++ autoreconf libtool)
missing=()

for tool in "${required[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done

if (( ${#missing[@]} > 0 )); then
    printf "error: missing build tools: %s\n" "${missing[*]}"
    printf "install on Debian: apt install make gcc g++ autoconf autotools-dev libtool git\n"
    exit 1
fi
