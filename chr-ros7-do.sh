##############################################
######  CHR ROS 7.18.1 on DigitalOcean  ######
##############################################
#!/bin/bash
curl https://download.mikrotik.com/routeros/7.18.1/chr-7.18.1.img.zip --output chr.img.zip  && \
=======
######  CHR ROS 7.16.2 on DigitalOcean  ######
##############################################
#!/bin/bash
curl https://download.mikrotik.com/routeros/7.16.2/chr-7.16.2.img.zip --output chr.img.zip  && \
>>>>>>> 39c21b85e15cbd4b29c19f15f3ed3f04f301b371
gunzip -c chr.img.zip > chr.img  && \
echo u > /proc/sysrq-trigger && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Wait 5 seconds" && \
sleep 5 && \
echo "All fine, I'll reboot the droplet, access to it only with recovery console" && \
echo b > /proc/sysrq-trigger
