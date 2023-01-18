#########################################
###### CHR ROS 7.5 on DigitalOcean ######
#########################################
#!/bin/bash
curl https://download.mikrotik.com/routeros/7.7/chr-7.7.img.zip --output chr.img.zip  && \
gunzip -c chr.img.zip > chr.img 
echo u > /proc/sysrq-trigger && \
sleep 5 && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo s > /proc/sysrq-trigger

