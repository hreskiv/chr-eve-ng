#!/bin/bash
####################################
# script is written by Ihor Hreskiv
# version 2.2
####################################
if [ $# -eq 1 ]; then
    ver=$1
    if [ -d "/opt/unetlab/addons/qemu/mikrotik-$ver/" ]; then
	echo "The version $ver of RouterOS is already installed"
	exit 0
    else
        echo "Creating nessessary directories"
        mkdir /opt/unetlab/addons/qemu/mikrotik-$ver/
        cd /opt/unetlab/addons/qemu/mikrotik-$ver/
        echo "getting image of CHR"
        wget https://download.mikrotik.com/routeros/$ver/chr-$ver.img.zip
        echo "Preparing the image"
        unzip chr-$ver.img.zip
        rm chr-$ver.img.zip
        mv chr-$ver.img hda.qcow2
        echo "Fixing permitions of the files"
        /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    fi;
else
    echo "Incorrect parameters."
    echo "Usage: sh chr-eve [VERSION]"
    echo "Where [VERSION] is the version of RouterOS"
    echo "Sample: sh cher-eve.sh 6.44.3"
fi
