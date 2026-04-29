#!/usr/bin/env bash
set -xeuo pipefail

git reset --hard
git pull -r
scripts/feeds update -a
scripts/feeds install -a
COMMON_CFLAGS="-O3 -pipe -fno-caller-saves -fno-plt -fno-semantic-interposition -flto-partition=one"
TUNING_CFLAGS="-mcpu=cortex-a53+crypto+crc -march=armv8-a+crc+crypto -mtune=cortex-a53"
sed -i "s/CPU_CFLAGS_cortex-a53 = -mcpu=cortex-a53/CPU_CFLAGS_cortex-a53 = $COMMON_CFLAGS $TUNING_CFLAGS/g" include/target.mk
sed -i "s/default \"-fno-caller-saves -fno-plt\"/default \"$COMMON_CFLAGS $TUNING_CFLAGS\"/g" config/Config-devel.in
cat <<EOF >> .config
CONFIG_USE_LTO=y
CONFIG_USE_GC_SECTIONS=y
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_dlink_aquila-pro-ai-m30-a1=y
CONFIG_EXPERIMENTAL=y
CONFIG_HTOP_LMSENSORS=y
CONFIG_LIBCURL_COOKIES=y
CONFIG_LIBCURL_FILE=y
CONFIG_LIBCURL_FTP=y
CONFIG_LIBCURL_HTTP=y
CONFIG_LIBCURL_HTTP2=y
CONFIG_LIBCURL_HTTP_AUTH=y
CONFIG_LIBCURL_MBEDTLS=y
CONFIG_LIBCURL_NO_SMB="!"
CONFIG_LIBCURL_PROXY=y
CONFIG_LIBCURL_UNIX_SOCKETS=y
CONFIG_LINUX_6_18=y
CONFIG_PACKAGE_adblock-fast=y
CONFIG_PACKAGE_attendedsysupgrade-common=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_btop=y
CONFIG_PACKAGE_cgi-io=y
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_coreutils-sort=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_gawk=y
CONFIG_PACKAGE_grep=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_iftop=y
CONFIG_PACKAGE_ip-tiny=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_iptables-nft=y
CONFIG_PACKAGE_kmod-ifb=y
CONFIG_PACKAGE_kmod-ip6tables=y
CONFIG_PACKAGE_kmod-ipt-conntrack=y
CONFIG_PACKAGE_kmod-ipt-core=y
CONFIG_PACKAGE_kmod-ipt-ipopt=y
CONFIG_PACKAGE_kmod-ipt-nat=y
CONFIG_PACKAGE_kmod-ipt-nat6=y
CONFIG_PACKAGE_kmod-iptables=y
CONFIG_PACKAGE_kmod-nf-ipt=y
CONFIG_PACKAGE_kmod-nf-ipt6=y
CONFIG_PACKAGE_kmod-nf-nat6=y
CONFIG_PACKAGE_kmod-nft-compat=y
CONFIG_PACKAGE_kmod-sched-cake=y
CONFIG_PACKAGE_kmod-sched-core=y
CONFIG_PACKAGE_libcurl=y
CONFIG_PACKAGE_libiptext=y
CONFIG_PACKAGE_libiptext-nft=y
CONFIG_PACKAGE_libiptext6=y
CONFIG_PACKAGE_libiwinfo=y
CONFIG_PACKAGE_libiwinfo-data=y
CONFIG_PACKAGE_liblucihttp=y
CONFIG_PACKAGE_liblucihttp-ucode=y
CONFIG_PACKAGE_libncurses=y
CONFIG_PACKAGE_libnghttp2=y
CONFIG_PACKAGE_libpcap=y
CONFIG_PACKAGE_libpcre2=y
CONFIG_PACKAGE_libpthread=y
CONFIG_PACKAGE_libreadline=y
CONFIG_PACKAGE_libstdcpp=y
CONFIG_PACKAGE_libxtables=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-app-adblock-fast=y
CONFIG_PACKAGE_luci-app-attendedsysupgrade=y
CONFIG_PACKAGE_luci-app-commands=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-package-manager=y
CONFIG_PACKAGE_luci-app-sqm=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-lib-uqr=y
CONFIG_PACKAGE_luci-light=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-mod-network=y
CONFIG_PACKAGE_luci-mod-status=y
CONFIG_PACKAGE_luci-mod-system=y
CONFIG_PACKAGE_luci-proto-ipv6=y
CONFIG_PACKAGE_luci-proto-ppp=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_resolveip=y
CONFIG_PACKAGE_rpcd=y
CONFIG_PACKAGE_rpcd-mod-file=y
CONFIG_PACKAGE_rpcd-mod-iwinfo=y
CONFIG_PACKAGE_rpcd-mod-luci=y
CONFIG_PACKAGE_rpcd-mod-rpcsys=y
CONFIG_PACKAGE_rpcd-mod-rrdns=y
CONFIG_PACKAGE_rpcd-mod-ucode=y
CONFIG_PACKAGE_sed=y
CONFIG_PACKAGE_sqm-scripts=y
CONFIG_PACKAGE_tc-tiny=y
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_terminfo=y
CONFIG_PACKAGE_ucode-mod-html=y
CONFIG_PACKAGE_ucode-mod-log=y
CONFIG_PACKAGE_ucode-mod-math=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
CONFIG_PACKAGE_xtables-nft=y
CONFIG_PCRE2_JIT_ENABLED=y
CONFIG_TESTING_KERNEL=y
CONFIG_PACKAGE_kmod-crypto-crc32c=y
EOF
make clean
make defconfig
scripts/diffconfig.sh
time make download
time make world -j32 # V=s
