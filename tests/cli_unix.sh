#!/bin/sh
set -e

../cli_unix.sh
secrethub --version

export SECRETHUB_CLI_VERSION=0.39.0
../cli_unix.sh
secrethub --version 2>&1 | grep "0.39.0"
