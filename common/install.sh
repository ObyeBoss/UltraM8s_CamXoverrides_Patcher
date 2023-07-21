COS="$(find $PARTITIONS -type f -name "camxoverridesettings*.txt")"
NOP="$(find /data/adb/modules -type f -name "camxoverridesettings*.txt")"
[ -f "/system/vendor/build.prop" ] && BUILDS="/system/build.prop /system/vendor/build.prop" || BUILDS="/system/build.prop"
QCP=$(grep -E "ro.board.platform=apq.*|ro.board.platform=msm.*|ro.board.platform=sdm.*" $BUILDS)
[ -z "$QCP" ] && QCP="$(cat /proc/cpuinfo | grep 'Qualcomm')"
mi10u=$(grep -E "ro.product.vendor.name=cas.*|ro.product.board=cas.*|ro.product.vendor.name=cmi.*|ro.product.board=cmi.*" $BUILDS)
mi11=$(grep -E "ro.product.vendor.name=star.*|ro.product.board=star.*|ro.product.vendor.name=venus.*|ro.product.board=venus.*|ro.product.vendor.name=mars.*|ro.product.board=mars.*" $BUILDS)
mi12=$(grep -E "ro.product.vendor.name=zeus.*|ro.product.board=zeus.*|ro.product.vendor.name=cupid.*|ro.product.board=cupid.*|ro.product.vendor.name=psyche.*|ro.product.board=psyche.*" $BUILDS)
xi=$(grep -E "ro.product.vendor.brand=Xiaomi|ro.product.vendor.brand=xiaomi|ro.product.vendor.manufacturer=Xiaomi|ro.product.vendor.manufacturer=xiaomi|ro.hardware.camera=xiaomi" $BUILDS)

get_cu() {
  case "$1" in
    "-u") cat $CU | sed 's/\r$//g' | tr '\r' '\n' > $CU.tmp; mv -f $CU.tmp $CU
            for UO in $(grep "^[A-Za-z_]*=" $CU | sed -e 's/=.*//g' -e 's/Version//g'); do
              eval "$UO=$(grep_prop "$UO" $CU)"
              sed -i "s|^$UO=|$UO=$(eval echo \$$UO)|" $MODPATH/camx_user
            done;;
    *) . $CU
       for UO in $(grep "^[A-Za-z_]*=" $CU | sed -e 's/=.*//g' -e 's/CVER//g'); do
         case $UO in
           "SMI"|"PF"|"HWT"|"CT"|"MRW"|"MRH"|"ADRC"|"FMF"|"DF"|"MAF"|"ELE"|"HJ"|"SF"|"EFB"|"AI"|"ESR"|"UPS"|"EG"|"ME"|"ET"|"MZ"|"XS"|"SG"|"ST"|"MG"|"MT"|"EMW"|"WBR"|"WBG"|"WBB"|"WBT"|"EV2"|"EV2FD"|"EV2M"|"EV3"|"EV3FD"|"EV3M") case "$(eval echo \$$UO | tr '[:upper:]' '[:lower:]')" in
                                                                                                                                                 " "*) eval "$UO=";;
                                                                                                                                               esac;;
           *) case "$(eval echo \$$UO | tr '[:upper:]' '[:lower:]')" in
                "true") eval "$UO=true";;
                *) eval "$UO=false";;
              esac;;
         esac
      done;;
  esac
}

#[ "$QCP" ] || abort "   This mod is suitable only for Qualcomm devices!"

if [ ! -f "$COS" ]; then 
ui_print " "
ui_print " - Camxoverride.txt doesn't exist, creating..."
ui_print " "
ui_print "     However its no guaranteed CO might"
ui_print "     get picked via HAL of your device"
ui_print " "
sleep 2
mktouch $MODPATH/$COS
#else
#cp_ch $COS $MODPATH/$COS
fi
CU="/storage/emulated/0/camx_user"
[ -f "$CU" ] && CVER=$(grep_prop CVER $CU)
ui_print " "
if [ -z "$CVER" ]; then
  [ -f $CU ] && ui_print "   Deprecated version of camx_user detected!" || ui_print "   ! CAMX_USER not detected !"
  ui_print "   Creating /sdcard/camx_user..."
  cp -f $MODPATH/camx_user $CU
elif [ $CVER -lt $(grep_prop CVER $MODPATH/camx_user) ]; then
  ui_print "   Older version of camx_user detected!"
  ui_print "   Updating camx_user!"
  get_cu -u
  ui_print "   Using specified options"
else
  ui_print "   Up to date camx_user detected! "
  ui_print "   Using specified options"
fi
cat $CU | sed 's/\r$//g' | tr '\r' '\n' > $CU.tmp; mv -f $CU.tmp $CU
get_cu
for ONOP in ${NOP}; do
mv $ORIGDIR$ONOP $NOP.bak
sed -i 's/\t/  /g' $NOP
done

ui_print " "
ui_print " - Applying main patches"
ui_print " "
ui_print " "
sleep 2
for OCO in ${COS}; do
CO="$MODPATH$(echo $OCO | sed "s|^/vendor|/system/vendor|g")"
$KSU && CO="$(echo $CO | sed -e "s|^/odm|/system/odm|g" -e "s|^/my_product|/system/my_product|g")"
cp_ch $ORIGDIR$OCO $CO
sed -i 's/\t/  /g' $CO

#done
echo " " >> $CO
echo "##" >> $CO
echo "### UltraM8's CamXoverrides start" >> $CO
echo "fovcEnable=0" >> $CO
echo "enableInternalHALPixelStreamConfig=FALSE" >> $CO
echo "maxHalRequests=8" >> $CO
echo "enableThermalMitigation=FALSE" >> $CO
echo "disableSpeckleDetection=TRUE" >> $CO
echo "ifeClockFrequencyMHz=0xffffffff" >> $CO
#echo "ifeCamnocBandwidthMBytes=10640" >> $CO
#echo "ifeExternalBandwidthMBytes=10640" >> $CO
echo "ifeCamnocBandwidthMBytes=0xffffffff" >> $CO
echo "ifeExternalBandwidthMBytes=0xffffffff" >> $CO
echo "ifeBandwidthBoostCount=60" >> $CO
if [ "$xi" ]; then
#echo "miIfeCamnocBandwidthMBytes=10640" >> $CO
#echo "miIfeExternalBandwidthMBytes=10640" >> $CO
echo "miIfeCamnocBandwidthMBytes=0xffffffff" >> $CO
echo "miIfeExternalBandwidthMBytes=0xffffffff" >> $CO
echo "miIfeBandwidthBoostCount=60" >> $CO
fi
echo "overrideForceFSCapable=TRUE" >> $CO
echo "overrideMaxImageBufferCountRealTime=-1" >> $CO
echo "overrideMaxImageBufferCountNonRealTime=-1" >> $CO
echo "numPCRsBeforeStreamOn=0" >> $CO
echo "enableOfflineNoiseReprocess=0" >> $CO
echo "statsProcessingSkipFactor=0" >> $CO
echo "pdafHWEnable=TRUE" >> $CO
#
echo "isEarlysettingsEnable=TRUE" >> $CO
echo "isActuatorEarlyInitEnable=TRUE" >> $CO

ui_print " "
ui_print " - Do you want to force HDR?"
ui_print " "
sleep 2
ui_print "   Vol Up = Set iHDR, Vol Down = Skip"
ui_print " "
if $VKSEL; then

ui_print " "
ui_print " - Force iHDR mode? -"
ui_print " "
ui_print "   iHDR is one of different in-sensor-hdr modes"
ui_print "   control should exist on most recent devices"
ui_print "   you can test it setting Force Enable"
ui_print "   if something went wrong - reflash module"
ui_print "   selecting Force Disable"
ui_print " "
sleep 3
ui_print "   Vol Up = Force Enable, Vol Down = Force Disable"
ui_print " "
if $VKSEL; then
 echo "enableRawHDR=1" >> $CO
 echo "SupportedAlgoEngineHdr=3" >> $CO
 echo "selectIHDRUsecase=1" >> $CO
 echo "enableIHDRSnapshot=1" >> $CO
else
 echo "enableRawHDR=0" >> $CO
 echo "SupportedAlgoEngineHdr=0" >> $CO
 echo "selectIHDRUsecase=0" >> $CO
 echo "enableIHDRSnapshot=0" >> $CO
fi 

ui_print " "
ui_print " - Force SHDR mode? -"
ui_print " "
ui_print "   SHDR is another HDR mode used on qc devices"
ui_print "   control should exist on most recent devices"
ui_print "   you can test it setting Force Enable"
ui_print "   if something went wrong - reflash module"
ui_print "   selecting Force Disable"
ui_print " "
sleep 3
ui_print "   Vol Up = Force Enable, Vol Down = Force Disable"
ui_print " "
if $VKSEL; then
 echo "#8350+" >> $CO
 echo "setHDRMode=1" >> $CO
 echo "inSensorSHDRMode=TRUE" >> $CO
 echo "IsSHDRThreeExpMode=1" >> $CO
 echo "enable3expSHDRSnapshot=TRUE" >> $CO
 echo "setAutoHDRMode=1" >> $CO
 echo "#8550+" >> $CO
 echo "MFHDRHWEnable=1" >> $CO
 echo "EnableSHDRWithOfflineIFE=1" >> $CO
 echo "setHDRMode=0x3" >> $CO
else
 echo "#8350+" >> $CO
 echo "setHDRMode=0" >> $CO
 echo "inSensorSHDRMode=FALSE" >> $CO
 echo "IsSHDRThreeExpMode=0" >> $CO
 echo "enable3expSHDRSnapshot=FALSE" >> $CO
 echo "setAutoHDRMode=0" >> $CO
 echo "#8550+" >> $CO
 echo "MFHDRHWEnable=0" >> $CO
 echo "EnableSHDRWithOfflineIFE=0" >> $CO
 echo "setHDRMode=0x0" >> $CO
fi

fi

if [ "$mi10u" ] || [ "$mi11" ] || [ "$mi12" ]; then
ui_print " "
ui_print " - Do you want to force Full resolution?"
ui_print " "
sleep 2
ui_print "   Vol Up = Set fullres, Vol Down = Skip"
ui_print " "
if $VKSEL; then
ui_print " "
ui_print " - Set 48/50mp full resolution? -"
ui_print " "
ui_print "   Your Xiaomi device is likely to support"
ui_print "   full resolution RAW without serious HAL"
ui_print "   patching. This control will expose fullres"
ui_print "   to all apps that can utilize raw stream."
ui_print "   !Beware! if you set iHDR enabled in"
ui_print "   previous option - it might interfere with"
ui_print "   full resolution"
ui_print " "
sleep 3
ui_print "   Vol Up = Enable, Vol Down = Disable"
ui_print " "
if $VKSEL; then
 echo "exposeFullSizeForQCFA=TRUE" >> $CO
 echo "overrideForceSensorMode=0" >> $CO
 echo "useFeatureForQCFA=0" >> $CO
fi
fi
fi

if [ "$xi" ]; then
ui_print " "
ui_print " - Do you want to force disable Xiaomi AI"
ui_print "    and xiaomi postprocessing algorithms?"
ui_print " "
sleep 2
ui_print "   Vol Up = Force disable, Vol Down = Skip"
ui_print " "
if $VKSEL; then
ui_print "   Every xiaomi device has its internal"
ui_print "   postprocessing nodes for things like"
ui_print "   upscaling, beautification, some extra"
ui_print "   corrections."
ui_print "   You can try fully disabling that for"
ui_print "   probably less processed images"
ui_print " "
sleep 3
ui_print "   Vol Up = Disable, Vol Down = Skip"
ui_print " "
if $VKSEL; then
 echo "AIEnhancementVersion=34" >> $CO
 echo "algoCameraXEnabled=TRUE" >> $CO
 echo "algoSDKEnabled=TRUE" >> $CO
fi
fi
fi

ui_print " "
ui_print " - Parsing CamX_User selectables"
ui_print " "
ui_print " "
sleep 2

if [ "$SMI" ]; then
echo "overrideForceSensorMode=$SMI" >> $CO
fi

if [ "$PF" ]; then
echo "perFrameSensorMode=$PF" >> $CO
fi

if [ "$HWT" ]; then
echo "numWorkerThreads=$HWT" >> $CO
fi

if [ "$CT" ]; then
echo "numberOfCHIThreads=$CT" >> $CO
fi

if [ "$MRW" ]; then
echo "minReprocessInputWidth=$MRW" >> $CO
fi

if [ "$MRH" ]; then
echo "minReprocessInputHeight=$MRH" >> $CO
fi

if [ "$ADRC" ]; then
echo "disableADRC=$ADRC" >> $CO
fi

if [ "$FMF" ]; then
echo "forceMaxFPS=$FMF" >> $CO
fi

if [ "$DF" ]; then
echo "defaultMaxFPS=$DF" >> $CO
fi

if [ "$MAF" ]; then
echo "manualAf=$MAF" >> $CO
fi

if [ "$ELE" ]; then
echo "extendedTimeForLongExposure=$ELE" >> $CO
fi

if [ "$HJ" ]; then
echo "enableHJAF=$HJ" >> $CO
fi

if [ "$SF" ]; then
echo "maxNonHfrFps=$SF" >> $CO
fi

if [ $EFB == 1 ]; then
echo "enableAFB=1" >> $CO
fi
if [ $EFB == 0 ]; then
echo "enableAFB=0" >> $CO
fi

if [ $AI == 1 ] ; then
echo "enableAI=1" >> $CO
fi
if [ $AI == 0 ]; then
echo "enableAI=0" >> $CO
fi

if [ $EV2 == 1 ]; then
echo "EISV2Enable=1" >> $CO
fi
if [ $EV2 == 0 ]; then
echo "EISV2Enable=0" >> $CO
fi

if [ $ESR == 1 ]; then
echo "enableSensorRemosaic=1" >> $CO
fi
if [ $ESR == 0 ]; then
echo "enableSensorRemosaic=0" >> $CO
fi

if [ $UPS == 1 ]; then
echo "enableResolutionUpscale=1" >> $CO
fi
if [ $UPS == 0 ]; then
echo "enableResolutionUpscale=0" >> $CO
fi

if [ $EV3 == 1 ]; then
echo "EISV3Enable=1" >> $CO
fi
if [ $EV3 == 0 ]; then
echo "EISV3Enable=0" >> $CO
fi

if [ $EMW == 1 ]; then
echo "manualWhiteBalanceType=TRUE" >> $CO
fi
if [ $EMW == 0 ]; then
echo "manualWhiteBalanceType=FALSE" >> $CO
fi

if [ "$EG" ]; then
echo "exposureGain=$EG" >> $CO
echo "gain=$EG" >> $CO
fi
if [ "$ME" ]; then
echo "manualExposureType=$ME" >> $CO
fi

if [ $XS == 1 ]; then
echo "enableStaggerSupernight=1" >> $CO
fi
if [ $XS == 0 ]; then
echo "enableStaggerSupernight=0" >> $CO
fi

if [ "$ET" ]; then
echo "sensorExposureTime=$ET" >> $CO
echo "exposureTime=$ET" >> $CO
fi
if [ "$MZ" ]; then
echo "maxDigitalZoom==$MZ" >> $CO
fi
if [ "$SG" ]; then
echo "shortGain=$SG" >> $CO
fi
if [ "$ST" ]; then
echo "sensorShortExposureTime=$ST" >> $CO
fi
if [ "$MG" ]; then
echo "middleGain=$MG" >> $CO
fi
if [ "$MT" ]; then
echo "sensorMiddleExposureTime=$MT" >> $CO
fi

if [ "$WBR" ]; then
echo "rGain=$WBR" >> $CO
fi
if [ "$WBG" ]; then
echo "gGain=$WBG" >> $CO
fi
if [ "$WBB" ]; then
echo "BGain=$WBB" >> $CO
fi
if [ "$WBT" ]; then
echo "colorTemp=$WBT" >> $CO
fi

echo "#8150+" >> $CO
echo "enablePerRequestSync=TRUE" >> $CO
echo "enableNativeHEIF=TRUE" >> $CO
echo "enableCHIPartialData=0" >> $CO
echo "OISMaxWaitingTime=70" >> $CO
echo "NightOISMaxWaitingTime=70" >> $CO
echo "#8350+" >> $CO
echo "disableReleaseSensorCache=TRUE" >> $CO
echo "CaptureBufferImmediatelyRelease=FALSE" >> $CO
if [ "$xi" ]; then
echo "MIVISuperNightSupportMask=0x0707" >> $CO
echo "wideFovCropZoomRatio=0" >> $CO
echo "teleFovCropZoomRatio=0" >> $CO
fi
if [ "$mi12" ]; then
#ui_print " "
#ui_print " - mi12 detected, disabling SHDR"
#ui_print " "
echo "#mi12" >> $CO
echo "maxIspGainList=imx989,4.0" >> $CO
echo "InputInfoChecker=0" >> $CO
echo "enableSFEAlignment=FALSE" >> $CO
echo "enableDynamicModeSwitchVCUpdate=FALSE" >> $CO
fi
echo "#8550+" >> $CO
echo "AECGainThresholdForQCFA=30.0" >> $CO
echo "enableVSR=0x0" >> $CO
echo "enableSignal35Tombstone=FALSE" >> $CO
echo "FovCropCameraIDMask=0" >> $CO
echo "enableFovCrop=FALSE" >> $CO
echo "FovCropZoomRatio=0" >> $CO
#echo "wideFovCropZoomRatio=0" >> $CO
#echo "teleFovCropZoomRatio=0" >> $CO
echo "### UltraM8's CamXoverrides end" >> $CO
echo "##" >> $CO
done

ui_print " "
ui_print " "
ui_print " - Installation finished"
ui_print " "
