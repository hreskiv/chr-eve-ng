#!/bin/bash
###################################################
## Script for replacing CentOS 7 to CHR on VULTR 
###################################################
curl http://download2.mikrotik.com/routeros/6.40.9/chr-6.40.9.img.zip --output chr.img.zip  && \
yum install unzip -y && \
gunzip -c chr.img.zip > chr.img  && \
mount -o loop,offset=33554944 chr.img /mnt && \
ADDRESS=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip dns set servers=8.8.8.8
/ip service disable telnet
/ip service disable ftp
/ip service disable www
/ip service disable api
/ip service disable api-ssl
/user set 0 password=pass2019
 " > /mnt/rw/autorun.scr && \
umount /mnt && \
sleep 5 && \
echo u > /proc/sysrq-trigger && \
sleep 5 && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo s > /proc/sysrq-trigger
