#!/bin/bash

# git web
export GITUL='https://ghproxy.net/'
export PYTUL='-i https://pypi.tuna.tsinghua.edu.cn/simple'
export DNS='223.5.5.5'

# servername─────────────────────────────────────────────────
export NOEX_SNAME='test.opsp.test'
export NNAV_SNAME='phnav.opsp.test'
export OUT4_SNAME='phcdn.opsp.test'
export OUT6_SNAME='phcd6.opsp.test'

sudo xbps-install -S
sudo xbps-install -y bind-utils
# ENV ─────────────────────────────────────────────────
export Profile_DIR="$HOME/.config/app-profile"
export MAIN_DIR="/opt"
export WAPP_DIR="$MAIN_DIR/app-webgo"
export SAPP_DIR="$MAIN_DIR/app-shell"
export DATA_DIR="$MAIN_DIR/local-data"

export GROUP_NEED='aid_everybody'
export UNAME_USE='tom'

sudo mkdir -p $MAIN_DIR
sudo chmod 777 $MAIN_DIR
mkdir -p $Profile_DIR
mkdir -p $WAPP_DIR
mkdir -p $SAPP_DIR
mkdir -p $DATA_DIR/app-web
mkdir -p $MAIN_DIR/system
mkdir -p ~/.config

# vsv services
export SVSV_DIR="$MAIN_DIR/0svs"
export LOGS_DIR="$MAIN_DIR/0log"
export PIDS_DIR="$MAIN_DIR/0pid"
# export ACTI_DIR="$MAIN_DIR/0active"
mkdir -p $SVSV_DIR
mkdir -p $LOGS_DIR
mkdir -p $PIDS_DIR
# mkdir -p $ACTI_DIR

# 颜色设置─────────────────────────────────────────────────
export COLOR_H1_0=$(tput bold setaf 7 setab 2)
export COLOR_H1_1=$(tput bold setaf 7)
export COLOR_H2_0=$(tput setaf 23 setab 7)
export COLOR_H2_1=$(tput setaf 40)
export COLOR_END=$(tput sgr0)

# sudo echo "nameserver $DNS" >> /etc/resolv.conf
nslookup pypi.tuna.tsinghua.edu.cn

echo -e "${COLOR_H2_1}====网站解析完成=======${COLOR_END}"


# 安装程序函数─────────────────────────────────────────────────
Add_application(){
    # for example
    # Add_application ${WAPP_DIR} ${Dir_Name} ${Dir_inzp} ${Pack} ${Mode} "no/yes/singal" # 最后一个变量为压缩包是否包含第二层
    ##################################
    root_dir=$1
    dir_name=$2
    dir_inzp=$3

    pack=$4
    mode=$5

    dir_check=$6

    nslookup github.com
    nslookup github.tphome.cf

    echo ""
    echo -e "${COLOR_H2_0}====使用Add_application方法=======${COLOR_END}"
    echo -e "${COLOR_H2_1}[正在安装app: ${dir_name}]${COLOR_END}"

    # download
    cd $root_dir
    # 无第二层，需要建立文件夹
    if [ $dir_check == "no" ]; then
        echo  "加入文件夹$dir_name"
        mkdir $dir_name
        cd    $dir_name
    fi
    wget -t 3 -T 300 -U Mozilla/5.0 "${GITUL}${pack}"

    # unzip
    # mode=$(echo $pack | cut -d. -f2)
    case "$mode" in
        tar) echo "该文件为tar包"
        tar -xf ./*.tar*
        rm      ./*.tar*
        ;;
        zip) echo "该文件为zip包"
        unzip -q ./*.zip
        rm  ./*.zip
        ;;
        gz) echo "该文件为gz包"
        gzip -d ./*.gz
        ;;
        *) echo "未知后缀"
        ;;
    esac

    # 有二层文件夹，需要把解压出来的文件夹转移到指定的文件夹名称
    if [ $dir_check == "yes" ]; then
        cd $root_dir
        mv $dir_inzp $dir_name
    fi
}

Add_app_to_env() {
    # Add_app_to_env ${WAPP_DIR} ${Dir_Name} ${Bin_Name}
    root_dir=$1
    dir_name=$2
    bin_name=$3

    # link to the binary path
    cd ${root_dir}/${dir_name}
    chmod +x ${bin_name}
    cd ${root_dir}/bin
    ln -s ../${dir_name}/${bin_name} ./
}

# 安装docker目录 ────────────────────────────────────────────
Add_docker_bin(){
    # docker_arch="linux/arm64"
    # docker_name="neosmemo/memos:latest"
    # Add_docker_bin $docker_name $docker_arch $dir_name "/usr/local/memos" "$WAPP_DIR/doker-pull" "$WAPP_DIR"
    docker_name=$1
    docker_arch=$2
    dir_name=$3
    dir_insi=$4

    if [[ $5 == '' ]]
    then
        docker_dir="$WAPP_DIR/doker-pull"
    else
        docker_dir=$5
    fi
    if [[ $6 == '' ]]
    then
        root_dir="$WAPP_DIR"
    else
        docker_dir=$6
    fi

    nslookup auth.docker.io
    nslookup registry-1.docker.io

    echo ""
    echo -e "${COLOR_H2_0}=========================================${COLOR_END}"
    echo -e "${COLOR_H2_1}[正在安装docker: ${docker_name}]${COLOR_END}"

    cd $docker_dir
    rm -rf ./output
    ./docker-image-extract -p $docker_arch $docker_name

    # copy
    mkdir -p $root_dir/$dir_name

    cd $docker_dir/output
    cp -r $dir_insi  $WAPP_DIR/$dir_name
}


# 写入配置函数─────────────────────────────────────────────────
Add_supervisord_conf() {
# for example
# Add_supervisord_conf    ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" "$command_start" "$work_dir"
#──────────
dir_name=$1
user_mod=$2
starts_weight=$3
command_start=$4

if [[ $5 == '' ]]
then
    work_dir="${WAPP_DIR}/${dir_name}"
else
    work_dir=$5
fi

mkdir -p $SVSV_DIR
cat >$SVSV_DIR/${dir_name}.conf <<EOF
#${dir_name}
[program:${dir_name}]
command=${command_start}
directory=${work_dir}
process_name=${dir_name}
user=${user_mod}
stdout_logfile=${LOGS_DIR}/${dir_name}-st.log
priority=${starts_weight}

autostart=true
autorestart=true
startsecs=3
startretries=3
exitcodes=0,2
stopsignal=TERM
stopwaitsecs=10
stopasgroup=true
killasgroup=true
redirect_stderr=true
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=1
stdout_capture_maxbytes=0
stdout_events_enabled=true
EOF
}

Add_runit_conf() {
# for example
# Add_supervisord_conf    ${Dir_Name} "$LOGNAME:$GROUP_NEED" "10" $command_start "$work_dir"
#──────────
dir_name=$1
user_mod=$2
starts_weight=$3
command_start=$4

if [[ $5 == '' ]]
then
    work_dir="${WAPP_DIR}/${dir_name}"
else
    work_dir=$5
fi

if [[ $user_mod -eq 'root' ]]
then
    checkroot="exec chpst -u $user_mod"
fi

# start
mkdir -p $SVSV_DIR/$dir_name
cat > $SVSV_DIR/$dir_name/run <<EOF
#!/bin/bash
cd $work_dir
$checkroot $command_start
EOF
chmod +x $SVSV_DIR/$dir_name/run

# log
mkdir -p $SVSV_DIR/$dir_name/log
cat > $SVSV_DIR/$dir_name/log/run <<EOF
#!/bin/bash
$checkroot svlogd -ttt $LOGS_DIR/${dir_name}/
EOF
chmod +x $SVSV_DIR/$dir_name/log/run

}

# [void@void ~]$ ps axf -o pid,ppid,pgrp,euser,args
