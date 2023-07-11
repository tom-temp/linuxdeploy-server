#!/bin/bash
# 翻墙工具
# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# 设置变量 ======================================================================================================
docker_arch="linux/arm64"

export PORT_fileb="20050"
export PORT_memos="20051"
export PORT_micro="20052"
export PORT_stash="20053"
export PORT_codes="20054"
export PORT_ddnsg="20059"

# https://hub.docker.com/r/filebrowser/filebrowser/tags
# 00. filebrowser ========================================================================================
Dir_Name="app-D-filebrowser"

docker_name="filebrowser/filebrowser:latest"
docker_copy="filebrowser"


mkdir -p $WAPP_DIR/$Dir_Name
cat >  $WAPP_DIR/$Dir_Name/.filebrowser.json <<EOF
{
  "port": ${PORT_fileb},
  "baseURL": "",
  "address": "",
  "log": "$LOGS_DIR/app-D-filebrowser.log",
  "database": "$WAPP_DIR/$Dir_Name/database.db",
  "root": "$MAIN_DIR",
  "allowEdit": true,
  "allowNew": true
}
EOF

command_start="./filebrowser"

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"


# https://hub.docker.com/r/neosmemo/memos/tags
# https://github.com/usememos/memos
# 01. memos 配置 ========================================================================================
Dir_Name="app-D-memos"

docker_name="neosmemo/memos:latest"
docker_copy="usr/local/memos/*"

mkdir -p $WAPP_DIR/$Dir_Name/data
command_start="./memos --data ./data --mode prod --port $PORT_memos"

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

sudo xbps-install -y musl-bootstrap
ln -s /usr/lib/ld-musl-$(arch).so.1 $WAPP_DIR/$Dir_Name/libc.musl-$(arch).so.1

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"

# 02. microbin 配置 ========================================================================================
Dir_Name="app-D-microbin"

docker_name="danielszabo99/microbin:latest"
docker_copy="usr/bin/microbin"

command_start="./microbin --port $PORT_micro --highlightsyntax --editable"

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"

# 03. stash
# ========================================================================================
Dir_Name="app-D-stash"

docker_name="stashapp/stash:latest"
docker_copy="usr/bin/stash"

command_start="./stash --nobrowser -c ./stash.yaml --port $PORT_stash "

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"

# 04. vscode
# ========================================================================================
Dir_Name="app-D-code"

docker_name="codercom/code-server:latest"
docker_copy="usr/lib/code-server/*"

command_start="HOME=$HOME ./bin/code-server $HOME/Sync/"

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

mkdir -p "$HOME/Sync/"
mkdir -p "$HOME/.config/code-server"

cat > $HOME/.config/code-server/config.yaml  <<EOF
bind-addr: 0.0.0.0:${PORT_codes}
auth: password
password: tomtom
cert: false
EOF

envsubst < ${CONF_DIR}/basic-caddy/no-ex-code.caddy > ${WAPP_DIR}/basic-caddy/sites-enabled/no-ex-code.caddy
echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"


# https://hub.docker.com/r/jeessy/ddns-go/tags
# 09. DDNS-go ========================================================================================
Dir_Name="app-D-ddns-go"

docker_name="jeessy/ddns-go:latest"
docker_copy="app/ddns-go"

command_start="./ddns-go   -f 1800 -c ${WAPP_DIR}/${Dir_Name}/ddns-ali.conf -l 0.0.0.0:${PORT_ddnsg}"

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"
