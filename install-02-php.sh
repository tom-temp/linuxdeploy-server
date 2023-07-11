#!/bin/bash

# init =========================================================================================================
# 设置工作目录
export WORK_DIR=$(cd $(dirname $0); pwd)
export CONF_DIR="$WORK_DIR/config"

# 导入并写入配置
source ${WORK_DIR}/init0-env.sh

# PHP ===========================================================================================================
echo -e "${COLOR_H1_0}\################################################### ${COLOR_END}"
echo -e "${COLOR_H1_1}\[安装PHP-APP]_____________________________________${COLOR_END}"

sudo xbps-install -y php php-fpm php-sqlite php-gd php-imagick php-intl

sudo echo "extension=bz2"              >> /etc/php/php.ini
sudo echo "extension=curl"             >> /etc/php/php.ini
sudo echo "extension=gd"               >> /etc/php/php.ini
sudo echo "extension=intl"             >> /etc/php/php.ini
sudo echo "extension=exif"             >> /etc/php/php.ini
sudo echo "extension=openssl"          >> /etc/php/php.ini
sudo echo "extension=sqlite3"          >> /etc/php/php.ini
sudo echo "extension=pdo_sqlite"       >> /etc/php/php.ini
sudo echo ""                           >> /etc/php/php.ini
sudo echo "extension=iconv"            >> /etc/php/php.ini
sudo echo "extension=imagick"          >> /etc/php/php.ini
sudo echo "extension=zip"              >> /etc/php/php.ini
sudo echo "zend_extension=opcache"     >> /etc/php/php.ini
# echo "extension=ldap"             >> /etc/php/php.ini
# echo "extension=posix"            >> /etc/php/php.ini
# echo "extension=mysqli"           >> /etc/php/php.ini
# echo "extension=pdo_mysql"        >> /etc/php/php.ini
sudo sed -ri "s/^user =+.*/user = ${UNAME_USE}/"     /etc/php/php-fpm.d/www.conf
sudo sed -ri "s/^group =+.*/group = ${GROUP_NEED}/"  /etc/php/php-fpm.d/www.conf

# auto-start
command_start="/usr/sbin/php-fpm -RF"
Add_supervisord_conf "php" "root" "80" "$command_start" "$MAIN_DIR/system"


export port_allweb='20020'

# one-nav =====================================================================================================
mkdir ${WAPP_DIR}/php-onenav
cd    ${WAPP_DIR}/php-onenav
git clone --depth=1 https://gitee.com/tznb/OneNav.git .

mkdir -p ${DATA_DIR}/app-web/php-onenav
mv       ${WAPP_DIR}/php-onenav/data/* ${DATA_DIR}/app-web/php-onenav
rm -rf   ${WAPP_DIR}/php-onenav/data
ln -s    ${DATA_DIR}/app-web/php-onenav ${WAPP_DIR}/php-onenav/data

export   onenav_dir="${WAPP_DIR}/php-onenav"
envsubst < ${CONF_DIR}/basic-caddy/php-onenav.caddy > ${WAPP_DIR}/basic-caddy/sites-enabled/php-onenav.caddy


# other web====================================================================================================
mkdir ${WAPP_DIR}/php-allweb
cd    ${WAPP_DIR}/php-allweb
cp    ${CONF_DIR}/php/info.php ${WAPP_DIR}/php-allweb/index.php
wget https://raw.githubusercontent.com/kmvan/x-prober/master/dist/prober.php

export   allweb_dir="${WAPP_DIR}/php-allweb"
envsubst < ${CONF_DIR}/basic-caddy/php-allweb.caddy > ${WAPP_DIR}/basic-caddy/sites-enabled/php-allweb.caddy
