#!/system/bin/xbin/busybox sh
echo "######### File=Wlan.sh $(date) #########" >>${ServiceLog}
cnss_diag=/data/vendor/wifi/cnss_diag.conf
lock=/data/vendor/wifi/cnss_diag.lock
if [ ! -f ${lock} ]; then
echo "LOG_PATH_FLAG = 0" > ${cnss_diag}
echo "MAX_LOG_FILE_SIZE = 0" >> ${cnss_diag}
echo "MAX_ARCHIVES = 0" >> ${cnss_diag}
echo "MAX_PKTLOG_ARCHIVES = 0" >> ${cnss_diag}
echo "LOG_STORAGE_PATH = /dev/null" >> ${cnss_diag}
echo "AVAILABLE_MEMORY_THRESHOLD = 0" >> ${cnss_diag}
echo "MAX_LOG_BUFFER = 0" >> ${cnss_diag}
echo "MAX_PKTLOG_BUFFER = 0" >> ${cnss_diag}
echo "HOST_LOG_FILE = /dev/null" >> ${cnss_diag}
echo "FIRMWARE_LOG_FILE = /dev/null" >> ${cnss_diag}
echo "ENABLE_FLUSH_LOG = 0" >> ${cnss_diag}
echo "REAL_TIME_WRITE = 0" >> ${cnss_diag}
rm -rf /data/vendor/wifi/wlan_logs 
ln -sf /dev/null /data/vendor/wifi/wlan_logs 
rm -rf /data/vendor/wifi/sockets
mkdir /dev/socket/wifi
ln -sf /dev/socket/wifi /data/vendor/wifi/sockets
rm -rf /data/vendor/wifi/wpa/sockets 
mkdir /dev/socket/wpa
ln -sf /dev/socket/wpa /data/vendor/wifi/wpa/sockets 
mkdir /dev/socket/hostapd
rm -rf /data/vendor/wifi/hostapd/sockets
ln -sf /dev/socket/hostapd /data/vendor/wifi/hostapd/sockets
rm -rf /data/vendor/wifi/hostapd/ctrl
ln -sf /dev/socket/hostapd /data/vendor/wifi/hostapd/ctrl
echo "" > ${lock}
fi
mkdir /dev/socket/wifi
mkdir /dev/socket/wpa
mkdir /dev/socket/hostapd
