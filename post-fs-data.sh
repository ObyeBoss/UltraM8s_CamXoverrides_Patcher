#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}
killall -1 android.hardware.camera.provider@2.4-service_64
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

# Enable SELinux Permissive Mode at Boot
# setenforce 0
