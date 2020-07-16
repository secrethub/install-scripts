#!/bin/sh
set -e

# Colors
NO_COLOR="\033[0m"
OK_COLOR="\033[32;01m"
ERROR_COLOR="\033[31;01m"
WARN_COLOR="\033[33;01m"

# Detect architecture
ARCH=amd64
if [ $(getconf LONG_BIT) = 32 ]; then
    ARCH=386
fi

# Detect OS
UNAME=$(uname)
if [ "$UNAME" = "Darwin" ]; then
    OS=darwin
elif [ "$UNAME" = "Linux" ]; then
    OS=linux
else
    printf "${ERROR_COLOR}Cannot determine OS type. Exiting...${NO_COLOR}\n"
    exit;
fi

# Make sure we have root privileges if necessary
SUDO=""
if [ $(id -u) -ne 0 ]; then
    if ! [ $(command -v sudo) ]; then
        printf "${ERROR_COLOR}Installer requires root privileges. Please run this script as root.${NO_COLOR}\n"
        exit;
    fi

    SUDO="sudo"
fi

printf "${OK_COLOR}==> Creating directories${NO_COLOR}\n"
$SUDO mkdir -p /usr/local/secrethub/bin

if [ "${SECRETHUB_CLI_VERSION:-latest}" != "latest" ]; then
    VERSION=v${SECRETHUB_CLI_VERSION}
else
    # Retrieve latest version
    printf "${OK_COLOR}==> Retrieving latest version${NO_COLOR}\n"
    VERSION=$(curl --silent "https://api.github.com/repos/secrethub/secrethub-cli/releases/latest" | grep tag_name | awk -F\" '{ print $4 }')
fi

# Exit if version is already installed
if command -v secrethub >/dev/null 2>&1 && secrethub --version 2>&1 | cut -d "," -f 1 | grep -q "$(echo $VERSION | cut -c 2-)$"; then
    printf "${OK_COLOR}==> Version ${VERSION} is already installed${NO_COLOR}\n"
    exit 0
fi

printf "${OK_COLOR}==> Downloading version ${VERSION}${NO_COLOR}\n"
ARCHIVE_NAME=secrethub-$VERSION-$OS-$ARCH
LINK_TAR=https://github.com/secrethub/secrethub-cli/releases/download/$VERSION/$ARCHIVE_NAME.tar.gz

curl -fsSL $LINK_TAR | $SUDO tar -xz -C /usr/local/secrethub;

# Create symlink to add binary to $PATH
$SUDO ln -sf /usr/local/secrethub/bin/secrethub /usr/local/bin/secrethub
