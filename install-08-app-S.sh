#!/bin/bash
# 翻墙工具
# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# 01. syncthing ========================================================================================
sudo xbps-install -y syncthing
syncthing generate

Dir_Name="app-syncthing"
# start
command_start="bash -c 'HOME=$HOME /usr/bin/syncthing serve'"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start" "$HOME"

echo -e "${COLOR_H2_1}[syncthing安装完成]${COLOR_END}"


# 02. aria2 ========================================================================================
sudo xbps-install -y aria2

export AIRA_DIR="$WAPP_DIR/app-aria2"
Dir_Name="app-aria2"

export AIRA_DIR="$WAPP_DIR/$Dir_Name"
export DOWN_DIR="$DATA_DIR/1download"
mkdir -p $DOWN_DIR
mkdir -p $AIRA_DIR
cd $AIRA_DIR

git clone --depth=1 https://github.com/P3TERX/aria2.conf.git ./script

envsubst '$AIRA_DIR,$DATA_DIR,$DOWN_DIR' < "$CONF_DIR/aria2.conf" > $AIRA_DIR/config.conf
touch $AIRA_DIR/aria2.session

# start
command_start="/usr/bin/aria2c --conf-path=$AIRA_DIR/config.conf"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start" "$HOME"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"

# cron ========================================================================================
echo "0 * * * *  bash $AIRA_DIR/script/tracker.sh $AIRA_DIR/config.conf >> $LOGS_DIR/app-aria2-tracker.log" >> ~/.config/cron.update





