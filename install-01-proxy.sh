#!/bin/bash

# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# app ===========================================================================================================
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo -e "${COLOR_H1_1}\[安装Proxy-APP]_____________________________________${COLOR_END}"


# port-defind ────────────────────────────────────────
export PORT_web='20010'   # alist
export PORT_v2ray='20011' # v2ray
export PORT_notls='20012' # caddy


export v2ray_id=$(cat /proc/sys/kernel/random/uuid) # v2ray
export v2ray_path='abcdefg' # v2ray
# export UUID=$(cat /proc/sys/kernel/random/uuid)

# https://github.com/v2fly/v2ray-core/releases
# V2ray ─────────────────────────────────────────────
sudo xbps-install v2ray

# config
Dir_Name='proxy-v2ray'
mkdir -p $WAPP_DIR/$Dir_Name
envsubst '${PORT_v2ray}, ${v2ray_id}, ${v2ray_path}' < ${CONF_DIR}/proxy/v2ray.json > $WAPP_DIR/$Dir_Name/config.json
# autostart
command_start="/bin/v2ray run $WAPP_DIR/$Dir_Name/config.json"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start"

# https://github.com/alist-org/alist/releases
# alist ─────────────────────────────────────────────
# URL
# ARCH='amd64'
Git_Name='alist-org/alist'
ARCH='arm64'

Pack="https://github.com/${Git_Name}/releases/latest/download/alist-linux-${ARCH}.tar.gz"
Mode='tar'

Dir_Name='proxy-alist-G'
Dir_inzp="none"
Add_application ${WAPP_DIR} ${Dir_Name} ${Dir_inzp} ${Pack} ${Mode} "no"

cd $WAPP_DIR/$Dir_Name
mv alist-* alist

# autostart
command_start="./alist server"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start"

# caddy_file ─────────────────────────────────────────────
envsubst < ${CONF_DIR}/proxy/proxy.caddy       > $WAPP_DIR/basic-caddy/sites-enabled/proxy.caddy
envsubst < ${CONF_DIR}/proxy/proxy-notls.caddy > $WAPP_DIR/basic-caddy/sites-enabled/proxy-notls.caddy
