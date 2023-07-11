#!/bin/bash
# 翻墙工具-!!!!重点更新
# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# 设置变量 ======================================================================================================
export PORT_clash="20040"
export PORT_subto="20041"


# https://github.com/MetaCubeX/Clash.Meta/releases
# https://github.com/haishanh/yacd/releases
# 01. 翻墙 clash & yacd ========================================================================================
# clash ──────────────────────────
# ARCH='amd64'
ARCH='arm64'
VERS="1.14.2"
Git_Name="MetaCubeX/Clash.Meta"
Pack="https://github.com/${Git_Name}/releases/download/v${VERS}/clash.meta-linux-${ARCH}-v${VERS}.gz"
Mode="gz"

Dir_Name="net-G-clash"
Dir_inzp="none"
Add_application ${WAPP_DIR} ${Dir_Name} ${Dir_inzp} ${Pack} ${Mode} "no"
cd ${WAPP_DIR}/${Dir_Name}
mv clash.meta* clash
chmod +x clash
touch $WAPP_DIR/$Dir_Name/config.yaml

# web ──────────────────────────
Git_Name="haishanh/yacd"
Pack="https://github.com/${Git_Name}/releases/latest/download/yacd.tar.xz"
Mode="tar"

Dir_web="dashboard"
Dir_inzp="public"
Add_application "${WAPP_DIR}/${Dir_Name}" ${Dir_web} ${Dir_inzp} ${Pack} ${Mode} "yes"

# start ──────────────────────────
command_start="./clash -f ./config.yaml -d $WAPP_DIR/$Dir_Name"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"


# https://github.com/tindy2013/subconverter/releases
# 02. 翻墙 订阅===========================================================================================
# ARCH='linux64'
ARCH='aarch64'
Git_Name="tindy2013/subconverter"
Pack="https://github.com/${Git_Name}/releases/latest/download/subconverter_${ARCH}.tar.gz"
Mode="tar"

Dir_Name="net-G-subconverter"
Dir_inzp="subconverter"
Add_application ${WAPP_DIR} ${Dir_Name} ${Dir_inzp} ${Pack} ${Mode} "yes"


# config ──────────────────────────
mkdir -p ${WAPP_DIR}/${Dir_Name}/web
mkdir -p ${WAPP_DIR}/${Dir_Name}/profiles
# web file
unzip -q -d ${WAPP_DIR}/${Dir_Name}/web  ${CONF_DIR}/app-subconverter/web.zip
# conf-file
cp -r $CONF_DIR/app-subconverter/*           ${WAPP_DIR}/${Dir_Name}/profiles/
rm ${WAPP_DIR}/${Dir_Name}/profiles/web.zip
rm ${WAPP_DIR}/${Dir_Name}/profiles/pref.yml

# PORT_subto PORT_clash
envsubst < ${CONF_DIR}/app-subconverter/pref.yml        > ${WAPP_DIR}/${Dir_Name}/pref.yml
#
# envsubst < ${CONF_DIR}/app-subconverter/base_simple.yml > ${WAPP_DIR}/${Dir_Name}/profiles/base_rule_my_clash.yml
# rules
git clone --depth 1 -b master https://github.com/ACL4SSR/ACL4SSR.git ${WAPP_DIR}/${Dir_Name}/ACL4SSR

# start ──────────────────────────
command_start="./subconverter"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start"

