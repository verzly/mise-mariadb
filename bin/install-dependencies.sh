#!/bin/sh
set -eu

if [ -f /etc/os-release ]; then
	. /etc/os-release
fi

if [ -f /etc/debian_version ]; then
	DISTRO=debian
elif [ -f /etc/redhat-release ]; then
	DISTRO=rhel
# elif [ "$(uname -s)" = "Darwin" ]; then
# 	DISTRO=darwin
else
	echo "Unsupported operating system"
	exit 1
fi

if command -v sudo; then
	SUDO=sudo
else
	SUDO=
fi

case $DISTRO in
	debian)
		export DEBIAN_FRONTEND=nointeractive
		$SUDO apt-get update -q
		$SUDO apt-get install -q -y --no-install-recommends \
			libcrypt1
		;;
	rhel)
		$SUDO dnf install -y yum-utils epel-release
		if [[ "$VERSION_ID" =~ ^8 ]]; then
			$SUDO dnf install -y dnf-plugins-core
			$SUDO dnf config-manager --set-enabled powertools
		elif [[ "$VERSION_ID" =~ ^9 ]]; then
			$SUDO dnf install -y dnf-plugins-core
			$SUDO dnf config-manager --set-enabled crb
		else
			$SUDO dnf install -y dnf-plugins-core
			$SUDO dnf config-manager --set-enabled crb
		fi
		$SUDO dnf install -y \
			libxcrypt-compat
		;;
	*)
esac
