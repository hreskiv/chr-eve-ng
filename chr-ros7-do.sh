#########################################
###### CHR ROS 7.8 on DigitalOcean ######
#########################################
#!/bin/bash
curl https://download.mikrotik.com/routeros/7.10.1/chr-7.10.1img.zip --output chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
echo u > /proc/sysrq-trigger && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Wait 5 seconds" && \
sleep 5 && \
echo "All fine, I'll reboot the droplet, access to it only with recovery console" && \
echo b > /proc/sysrq-trigger
