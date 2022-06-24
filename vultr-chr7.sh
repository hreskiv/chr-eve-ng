#!/bin/bash
echo "Downloading CHR 7.3.1 img from MikroTik"
wget https://download.mikrotik.com/routeros/7.3.1/chr-7.3.1.img.zip 
unzip chr-7.3.1.img.zip
dd if=chr-7.3.1.img of=/dev/vda

echo "In Settings menu of your instance select Remove ISO"

