#!/bin/bash
echo "Creating nessessary directories"
mkdir /opt/unetlab/addons/qemu/mikrotik-6.44.2/
cd /opt/unetlab/addons/qemu/mikrotik-6.44.2/
echo "getting image of CHR"
wget https://download.mikrotik.com/routeros/6.44.2/chr-6.44.2.img.zip
echo "Preparing the image"
unzip chr-6.44.2.img.zip
rm chr-6.44.2.img.zip
mv chr-6.44.2.img hda.qcow2
echo "Fixing permitions of the files"
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions
