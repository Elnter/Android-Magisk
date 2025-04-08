#!/system/bin/xbin/busybox sh
echo "######### File=Swap.sh $(date) #########" >>"${ServiceLog}"

Function=0

if [[ "${Function}" == "0" ]]; then

echo 1 > /proc/sys/vm/swap_ratio_enable;
echo 100 > /proc/sys/vm/swappiness;

else

Path=/data/swap;

Max=29
ZramSize=2048

if [ ! -d "$Path" ];then
mkdir $Path;
for i in $(seq 1 $Max)
do
dd if=/dev/zero of=$Path/swapfile$i count=$(($i*2)) bs=1048576;
echo $Path/swapfile$i;
done
fi;

swapoff /dev/block/zram0
echo 1 > /sys/class/block/zram0/reset
echo 8 > /sys/class/block/zram0/max_comp_streams
echo $(($ZramSize*1024*1024)) > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0

for i in $(seq 1 $Max)
do
mkswap $Path/swapfile$i;
swapon $Path/swapfile$i;
done

echo 1 > /proc/sys/vm/swap_ratio_enable;
echo 75 > /proc/sys/vm/swappiness;

fi
cat /proc/swaps;
