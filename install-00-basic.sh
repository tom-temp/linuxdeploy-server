#!/bin/bash


# install for dependency of appimage and sv-manager
sudo xbps-install -S
sudo xbps-install -y fuse vsv
sudo xbps-install -y unzip xz
sudo xbps-install -y wget unzip curl git dcron shadow gettext python
# python3 vim  figlet openssl

# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"
chmod +x $WORK_DIR/*.sh

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

echo "export MAIN_DIR=$MAIN_DIR"     >> ~/.profile
echo "export WAPP_DIR=$WAPP_DIR"     >> ~/.profile
echo "export SAPP_DIR=$SAPP_DIR"     >> ~/.profile
echo "export DATA_DIR=$DATA_DIR"     >> ~/.profile

echo "export SVSV_DIR=$SVSV_DIR"     >> ~/.profile
echo "export LOGS_DIR=$LOGS_DIR"     >> ~/.profile

echo "export GROUP_NEED=$GROUP_NEED" >> ~/.profile
echo "export GITUL=$GITUL"           >> ~/.profile

echo "export COLOR_H1_0='\e[1;35;42m'"  | tee -a ~/.profile $MAIN_DIR/system/root-profile
echo "export COLOR_H1_1='\e[4;30;46m'"  | tee -a ~/.profile $MAIN_DIR/system/root-profile
echo "export COLOR_H2_1='\e[1;32;40m'"  | tee -a ~/.profile $MAIN_DIR/system/root-profile
echo "export COLOR_END='\e[0m'"         | tee -a ~/.profile $MAIN_DIR/system/root-profile

# echo "COLOR_H1_0='${COLOR_H1_0}'" | tee -a ~/.profile $MAIN_DIR/system/root-profile
# echo "COLOR_H1_1='${COLOR_H1_1}'" | tee -a ~/.profile $MAIN_DIR/system/root-profile
# echo "COLOR_H2_0='${COLOR_H2_0}'" | tee -a ~/.profile $MAIN_DIR/system/root-profile
# echo "COLOR_H2_1='${COLOR_H2_1}'" | tee -a ~/.profile $MAIN_DIR/system/root-profile
# echo "COLOR_END='${COLOR_END}'"   | tee -a ~/.profile $MAIN_DIR/system/root-profile

# 用户管理 ──────────────────────────────────────────
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo -e "${COLOR_H1_1}\[设置用户]_增加用户${UNAME_USE}, 属于${GROUP_NEED}__${COLOR_END}"
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo

sudo gpasswd -a $UNAME_USE $GROUP_NEED
sudo chgrp -R $GROUP_NEED $MAIN_DIR
sudo chmod 775 -R $MAIN_DIR


# supervisor port
export PORT_supervisor='20000'
export PORT_sshd_20001='20001'


# app ===========================================================================================================
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo -e "${COLOR_H1_1}\[安装APP]_安装需要的app_____________________________${COLOR_END}"
echo -e "${COLOR_H1_0}\░█▀█░█▀█░█▀█${COLOR_END}"
echo -e "${COLOR_H1_0}\░█▀█░█▀▀░█▀▀${COLOR_END}"
echo -e "${COLOR_H1_0}\░▀░▀░▀░░░▀░░${COLOR_END}"
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"

# https://github.com/ochinchina/supervisord/releases
#01.supervisor ─────────────────────────────────────────────
# URL
# ARCH='Linux_64-bit'
Git_Name='ochinchina/supervisord'
ARCH='Linux_ARM64'
VERS='0.7.3'

Pack="https://github.com/${Git_Name}/releases/latest/download/supervisord_${VERS}_${ARCH}.tar.gz"
Mode='tar'

Dir_Name='basic-supervisord'
Dir_inzp='supervisord_*'
echo -e "${COLOR_H2_1}\=====<<<${Dir_Name}>>>===== ${COLOR_END}"
echo
Add_application ${WAPP_DIR} ${Dir_Name} ${Dir_inzp} ${Pack} ${Mode} "yes"

# ${PIDS_DIR},${SVSV_DIR},${LOGS_DIR}
envsubst < ${CONF_DIR}/basic-supervisord.conf > $WAPP_DIR/$Dir_Name/supervisord.conf

# $WAPP_DIR/$Dir_Name/supervisord -c $WAPP_DIR/$Dir_Name/supervisord.conf -d
echo "alias supervisorctl='$WAPP_DIR/$Dir_Name/supervisord \
            ctl -s http://127.0.0.1:$PORT_supervisor -u tom -P tom-tom@'" >> ${Profile_DIR}/alias.sh

# 开机脚本 ─────────────────────
cat  >$MAIN_DIR/system/rc.d.start.sh <<EOF
#!/bin/bash
StartSupervisor(){
    $WAPP_DIR/$Dir_Name/supervisord -c $WAPP_DIR/$Dir_Name/supervisord.conf -d
}
StartSupervisor

EOF

cat  >>$MAIN_DIR/system/rc.d.start.sh <<\EOF
sleep 10
var_zero=0
status_supervisor=$(ps -ef | grep supervisord | grep -v 'grep' | grep -v 'rg')
while (( ${#status_supervisor} == ${var_zero} ))
do
    echo '发现supervisor未启动' >> /opt/rc.log
    echo '现在status_supervisor的值为：'$status_supervisor >> /opt/rc.log
    # 使用函数
    StartSupervisor
    sleep 10
    status_supervisor=$(ps -ef | grep supervisord | grep -v 'grep' | grep -v 'rg')
    echo '现在status_supervisor的值为：'$status_supervisor >> /opt/rc.log
done
echo '[# 启动supervisor完成]' >> /opt/rc.log
EOF

chmod +x $MAIN_DIR/system/rc.d.start.sh

#01.ssh 与 cron ─────────────────────────────────────────────
Add_supervisord_conf "A-sshd" "root" "70" "/usr/sbin/sshd -D -p $PORT_sshd_20001" "$MAIN_DIR/system"
Add_supervisord_conf "A-cron" "root" "70" "/usr/sbin/crond -f" "$MAIN_DIR/system"

#02.docker pull ─────────────────────────────────────────────
DOWN_DOCKERPULL="${GITUL}https://github.com/jjlin/docker-image-extract/blob/main/docker-image-extract"
mkdir $WAPP_DIR/doker-pull
cd    $WAPP_DIR/doker-pull
wget -t 3 -T 300 -U Mozilla/5.0 $DOWN_DOCKERPULL  # -e "http_proxy=http://192.168.2.20:2001"
chmod +x docker-image-extract




# 03.caddy ───────────────────────────────────────────────
DOWN_CADDY='https://caddyserver.com/api/download?os=linux&arch=arm64'
# https_proxy=192.168.2.20:2001 http_proxy=192.168.2.20:2001 \

Dir_Name='basic-caddy'
mkdir -p $WAPP_DIR/$Dir_Name/sites-enabled
cd       $WAPP_DIR/$Dir_Name

# config
cp $CONF_DIR/basic-caddy/Caddyfile $WAPP_DIR/$Dir_Name/Caddyfile
# config
command_start="$WAPP_DIR/$Dir_Name/caddy run --environ --config $WAPP_DIR/$Dir_Name/Caddyfile"

Add_supervisord_conf $Dir_Name "root" "70" "$command_start" "$MAIN_DIR/system"

# caddy download
wget $DOWN_CADDY -O caddy
./caddy add-package \
github.com/mholt/caddy-webdav \
github.com/kirsch33/realip \
github.com/caddy-dns/alidns \
github.com/caddy-dns/cloudflare \
github.com/caddyserver/transform-encoder

chmod +x $WAPP_DIR/$Dir_Name/caddy
