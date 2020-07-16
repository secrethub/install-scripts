#!/bin/bash

set -e

# Colors
NO_COLOR="\033[0m"
OK_COLOR="\033[32;01m"
ERROR_COLOR="\033[31;01m"
WARN_COLOR="\033[33;01m"

# Detect Architecture
ARCH=amd64
if [ $(getconf LONG_BIT) == 32 ]; then
    ARCH=386
fi

# Detect OS
UNAME=$(uname)
if [[ "$UNAME" == "Darwin" ]]; then
	OS=darwin
elif [[ $UNAME == "Linux" ]]; then
    OS=linux
else
    echo -e "${ERROR_COLOR}Cannot determine OS type. Exiting...${NO_COLOR}"
    exit;
fi

# Make sure we have root priviliges.
SUDO=""
if [[ $(id -u) -ne 0 ]]; then
    if ! [[ $(command -v sudo) ]]; then
        echo -e "${ERROR_COLOR}Installer requires root privileges. Please run this script as root.${NO_COLOR}"
        exit;
    fi

    if ! sudo -n true 2>/dev/null; then
        echo -e "${OK_COLOR}==> I need root privileges to continue, please type in your password.${NO_COLOR}"
        sudo -v
    fi

    SUDO="sudo"
fi

echo -e "${OK_COLOR}==> Creating directories${NO_COLOR}"
$SUDO mkdir -p /usr/local/secrethub/bin

# Retrieve latest version
echo -e "${OK_COLOR}==> Retrieving latest version${NO_COLOR}"
VERSION=$(curl --silent "https://api.github.com/repos/secrethub/secrethub-cli/releases/latest" | grep tag_name | awk -F\" '{ print $4 }')

echo -e "${OK_COLOR}==> Downloading latest version${NO_COLOR}"
ARCHIVE_NAME=secrethub-$VERSION-$OS-$ARCH
LINK_TAR=https://github.com/secrethub/secrethub-cli/releases/download/$VERSION/$ARCHIVE_NAME.tar.gz

curl -fsSL $LINK_TAR | $SUDO tar -xz  -C /usr/local/secrethub;

# symlink in the PATH
$SUDO ln -sf /usr/local/secrethub/bin/secrethub /usr/local/bin/secrethub
