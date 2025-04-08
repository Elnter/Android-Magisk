#!/system/bin/xbin/busybox sh
echo "######### File=Property.sh $(date) #########" >>"${ServiceLog}"

Task=/dev/var/tmp/cache/Task
ps -ef > ${Task}
renice_Priority=-20
chrt_Priority=99
Max=9

for i in $(seq 0 $Max)
do
PID=$(grep -F "[dp_rx_thread_${i}]" ${Task} | awk '{print $2}')
if [[ ${PID} != "" ]]; then
chrt -f -p ${chrt_Priority} ${PID}
renice -n ${renice_Priority} ${PID}
continue
fi
done

for i in $(seq 0 $Max)
do
PID=$(grep -F "[kworker/u16:${i}-rmnet_shs_wq]"  ${Task} | awk '{print $2}')
if [[ ${PID} != "" ]]; then
chrt -f -p ${chrt_Priority} ${PID}
renice -n ${renice_Priority} ${PID}
continue
fi
done

PID=$(grep -F "system_server" ${Task} | awk '{print $2}')
chrt -r -p ${chrt_Priority} ${PID}
renice -n ${renice_Priority} ${PID}

PID=$(grep -F "vndservicemanager" ${Task} | awk '{print $2}')
chrt -r -p ${chrt_Priority} ${PID}
renice -n ${renice_Priority} ${PID}

PID=$(grep -F "surfaceflinger" ${Task} | awk '{print $2}')
chrt -r -p ${chrt_Priority} ${PID}
renice -n ${renice_Priority} ${PID}
rm -rf ${Task}