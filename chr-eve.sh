#!/bin/bash
####################################
# script is written by Ihor Hreskiv
# version 2.4.2
####################################
if [ $# -eq 1 ]; then
    ver=$1
    case $1 in
      fix)
          /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
          echo "Fixing permitions of the files"
          exit 0
          ;;
      list)
          echo "List of installed QEMU templates"
          ls -l /opt/unetlab/addons/qemu | awk '{print $9}'
          exit 0
          ;;
      *)
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
          ;;
    esac
else
    echo "Incorrect parameters."
    echo "Usage: sh chr-eve [VERSION] | [fix] | [list]"
    echo "Where [VERSION] is the version of RouterOS"
    echo "fix - fix the permitions of files"
    echo "list - list of installed qemu images"
    echo "Sample: sh chr-eve.sh 6.46.5"
fi
