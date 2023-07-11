

mount -t proc proc proc/
echo "domain lan" >> /etc/resolv.conf
echo "nameserver 192.168.2.251" >> /etc/resolv.conf

mkdir -p /etc/xbps.d

cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
echo "repository=https://mirrors.tuna.tsinghua.edu.cn/voidlinux/current" > /etc/xbps.d/00-repository-main.conf


xbps-install -S
xbps-install base-devel cmake gcc-objc++ readline-devel
xbps-install linux5.19-headers
