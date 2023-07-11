#!/bin/bash

# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# 设置变量 ======================================================================================================
PORT_gitea="20030"
PORT_sshea="20031"
NAME_gitea="phgit.opsp.test"
export PORT_vault="20032"
export PORT_vauws="20033"
export NAME_vault='phvault.opsp.test'
DIR_Gitea_data="/opt/0gitea/gitea"

# app ===========================================================================================================
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo -e "${COLOR_H1_1}\[安装SSL-APP]_______________________________________${COLOR_END}"

#https://dl.gitea.io/gitea
# gitea ─────────────────────────────────────────────
sudo xbps-install -y gitea

Dir_Name='ssl-gitea'
mkdir -p ${WAPP_DIR}/${Dir_Name}
mkdir -p $DIR_Gitea_data
ln    -s $DIR_Gitea_data ${WAPP_DIR}/${Dir_Name}/data

git config --global --add safe.directory "*"

cat >${WAPP_DIR}/${Dir_Name}/app.ini <<EOF
[server]
START_SSH_SERVER = true
HTTP_PORT        = ${PORT_gitea}
SSH_PORT         = ${PORT_sshea}
SSH_DOMAIN       = ${NAME_gitea}
DOMAIN           = ${NAME_gitea}
[database]
DB_TYPE  = sqlite3
PATH     = ${WAPP_DIR}/${Dir_Name}/data/gitea.db
[repository]
ROOT     = ${WAPP_DIR}/${Dir_Name}/data/gitea-repositories
EOF

# autostart
command_start="/bin/gitea web -c $WAPP_DIR/$Dir_Name/app.ini -w ${WAPP_DIR}/${Dir_Name}"
Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "$command_start"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"


# vault ─────────────────────────────────────────────
sudo xbps-install -y vaultwarden vaultwarden-web

Dir_Name='ssl-vault'
mkdir -p ${WAPP_DIR}/${Dir_Name}
cd ${WAPP_DIR}/${Dir_Name}

ln    -s /usr/share/webapps/vaultwarden-web ./web-vault
mkdir -p ${DATA_DIR}/app-web/${Dir_Name}
ln    -s ${DATA_DIR}/app-web/${Dir_Name} ${WAPP_DIR}/${Dir_Name}/data

cat >${WAPP_DIR}/${Dir_Name}/.env <<EOF
ROCKET_ADDRESS=0.0.0.0
ROCKET_PORT=${PORT_vault}
WEBSOCKET_PORT=${PORT_vauws}
WEBSOCKET_ENABLED=true
LOG_FILE=${LOGS_DIR}/vaultwarden.log
LOG_LEVEL=warn
EXTENDED_LOGGING=true
ADMIN_TOKEN=`openssl rand -base64 48`
#ROCKET_TLS={certs="/data/cert/fullchain.pem",key="/data/cert/key.pem"}
EOF

Add_supervisord_conf "$Dir_Name" "$UNAME_USE:$GROUP_NEED" "50" "/bin/vaultwarden"

echo -e "${COLOR_H2_1}[${Dir_Name}安装完成]${COLOR_END}"

# caddy_file ─────────────────────────────────────────────
envsubst < ${CONF_DIR}/basic-caddy/ssl-vault.caddy > $WAPP_DIR/basic-caddy/sites-enabled/ssl-vault.caddy
