#########################################
###### CHR ROS 7.5 on DigitalOcean ######
#########################################
#!/bin/bash
curl https://download.mikrotik.com/routeros/7.5/chr-7.5.img.zip --output chr.img.zip  && \
gunzip -c chr.img.zip > chr.img 
echo u > /proc/sysrq-trigger && \
sleep 5 && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo s > /proc/sysrq-trigger

