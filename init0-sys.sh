#!/bin/sh

# use root
gpasswd -a root aid_inet
gpasswd -a root aid_graphics
gpasswd -a root aid_sdcard_rw
# 设置镜像源
mkdir -p /etc/xbps.d

cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
echo "repository=https://mirrors.tuna.tsinghua.edu.cn/voidlinux/current" > /etc/xbps.d/00-repository-main.conf
xbps-install -S

xbps-install -yu xbps
xbps-install -y void-repo-nonfree
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://mirrors.tuna.tsinghua.edu.cn/voidlinux|g' /etc/xbps.d/*-repository-*.conf
sed -i 's|https://mirrors.servercentral.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/xbps.d/*-repository-*.conf
# delete useless pacage
# update
# xbps-remove -R  lvm2  efibootmgr
# xbps-remove -R grub-i386-efi grub-x86_64-efi grub
# echo "ignorepkg=wifi-firmware"      >> /etc/xbps.d/10-ignore.conf
# echo "ignorepkg=zd1211-firmware"    >> /etc/xbps.d/10-ignore.conf
# echo "ignorepkg=ipw2200-firmware"   >> /etc/xbps.d/10-ignore.conf
# echo "ignorepkg=ipw2100-firmware"   >> /etc/xbps.d/10-ignore.conf
# echo "ignorepkg=iw"                 >> /etc/xbps.d/10-ignore.conf
# echo "ignorepkg=wpa_supplicant"     >> /etc/xbps.d/10-ignore.conf
# xbps-remove -R wifi-firmware zd1211-firmware ipw2200-firmware ipw2100-firmware iw wpa_supplicant

# update kernel
xbps-install -S
xbps-install -Syu

# del old kernel
# vkpurge list
# vkpurge rm all
sudo gpasswd -a tom aid_everybody
sudo usermod -u 10255 tom


# opt目录

dd if=/dev/zero of=./mynamet.img bs=4M count=950
dd if=/dev/zero of=./alpine.img bs=4M count=200






# use sv
# if you use chroot > runit, you should delete the default services
rm /etc/runit/runsvdir/default/*

echo "mkdir -p /run/runit/runsvdir" >> /etc/rc.local
echo "ln -s /etc/runit/runsvdir/current /run/runit/runsvdir/current" >> /etc/rc.local






# /usr/local/bin/runsvdir -P /var/service


env - PATH=$PATH  runsvdir -P /run/runit/runsvdir/current 'log: ...'






