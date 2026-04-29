#!/usr/bin/env bash
set -xeuo pipefail

SCRIPT_DIR=${0%/*}

git pull -r https://github.com/openwrt/openwrt.git main
scripts/feeds update -a
scripts/feeds install -a

PACKAGES_FROM_FIRMWARE_SELECTOR="apk-mbedtls base-files ca-bundle dnsmasq dropbear firewall4 fitblk fstools kmod-crypto-hw-safexcel kmod-gpio-button-hotplug kmod-leds-gpio kmod-nft-offload libc libgcc libustream-mbedtls logd mtd netifd nftables odhcp6c odhcpd-ipv6only ppp ppp-mod-pppoe procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-mbedtls kmod-leds-gca230718 kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware luci luci-app-attendedsysupgrade"
MY_PACKAGES="luci-app-adblock-fast gawk grep sed coreutils-sort dnsmasq-full ipset libnettle8 libnetfilter-conntrack3 ip6tables-mod-nat kmod-ipt-nat6 luci-app-sqm btop"
PACKAGES="$PACKAGES_FROM_FIRMWARE_SELECTOR $MY_PACKAGES"

COMMON_CFLAGS="-O3 -pipe -fno-caller-saves -fno-plt -fno-semantic-interposition -funroll-loops -fgraphite-identity -floop-nest-optimize -fsched-pressure -fipa-pta -flto-partition=one -fno-conserve-stack"
TUNING_CFLAGS="-mcpu=cortex-a53+crypto+crc -march=armv8-a+crc+crypto -mtune=cortex-a53"

cat <<EOF > .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_dlink_aquila-pro-ai-m30-a1=y

CONFIG_USE_LTO=y
CONFIG_USE_MOLD=y
CONFIG_USE_GC_SECTIONS=y

CONFIG_DEVEL=y

CONFIG_CCACHE=y
CONFIG_CCACHE_DIR="${CCACHE_DIR:-$SCRIPT_DIR/.ccache}"

CONFIG_OPTIMIZE_HOST_TOOLS=y
CONFIG_HOST_FLAGS_OPT="-O3 -pipe -fipa-pta"
CONFIG_HOST_TOOLS_STRIP=y
CONFIG_HOST_FLAGS_STRIP="-Wl,-s"
CONFIG_HOST_EXTRA_CFLAGS=""
CONFIG_HOST_EXTRA_CXXFLAGS=""
CONFIG_HOST_EXTRA_CPPFLAGS=""
CONFIG_HOST_EXTRA_LDFLAGS=""

CONFIG_TOOLCHAINOPTS=y
CONFIG_GCC_USE_VERSION_15=y
CONFIG_GCC_USE_GRAPHITE=y

CONFIG_BINUTILS_USE_VERSION_2_46=y

CONFIG_TARGET_OPTIONS=y
CONFIG_EXTRA_OPTIMIZATION="$COMMON_CFLAGS $TUNING_CFLAGS"
CONFIG_TARGET_OPTIMIZATION="$COMMON_CFLAGS $TUNING_CFLAGS"
CONFIG_KERNEL_CFLAGS="$COMMON_CFLAGS $TUNING_CFLAGS"

CONFIG_DOWNLOAD_TOOL_CUSTOM="aria2c"

$(for pkg in $PACKAGES; do echo "CONFIG_PACKAGE_$pkg=y"; done)
EOF

make defconfig
scripts/diffconfig.sh

if [ "${CLEAN_BUILD:-false}" = "true" ]; then
    make clean
fi

PROCS=$(nproc --all)
time make download -j$((PROCS * 2)) # V=1 or V=sc or V=s
time make world -j$((PROCS * 2)) V=1 # V=1 or V=sc or V=s
