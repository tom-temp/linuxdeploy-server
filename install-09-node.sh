#!/bin/bash
# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# nodejs =====================================================================================================
sudo xbps-install -y nodejs pnpm

mkdir $MAIN_DIR/pnpm

cd ~
pnpm config set store-dir      "$MAIN_DIR/pnpm/pnpm-store"
pnpm config set cache-dir      "$MAIN_DIR/pnpm/cache"
pnpm config set state-dir      "$MAIN_DIR/pnpm"
pnpm config set global-dir     "$MAIN_DIR/pnpm/pnpm-global"
pnpm config set global-bin-dir "$MAIN_DIR/pnpm/bin"
pnpm config set registry https://registry.npmmirror.com
# pnpm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass

# PiGallery2 =====================================================================================================
Dir_Name="node-D-pigallery2"

docker_name="bpatrik/pigallery2:latest-alpine"
docker_copy="usr/bin/stash"

command_start="./stash --nobrowser -c ./test.yaml --port $PORT_stash "

Add_docker_bin        $docker_name $docker_arch $Dir_Name $docker_copy "$WAPP_DIR/doker-pull"
Add_supervisord_conf  ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"







# Homepage =====================================================================================================

Dir_Name="node-homepage"
mkdir ${WAPP_DIR}/${Dir_Name}
cd    ${WAPP_DIR}/${Dir_Name}

git clone https://github.com/benphelps/homepage.git ./

pnpm install
pnpm build

command_start="cd ${WAPP_DIR}/${Dir_Name} && pnpm start"
Add_supervisord_conf ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"



