#!/system/bin/xbin/busybox sh
echo "######### File=CPU.sh $(date) #########" >>"${ServiceLog}"

chmod 0755 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient

echo "1" > /sys/devices/system/cpu/cpu0/core_ctl/enable
echo "0" > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
echo "4" > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
echo "307200" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo "1785600" > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy0/walt/adaptive_high_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy0/walt/adaptive_low_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy0/walt/boost

echo "1" > /sys/devices/system/cpu/cpu4/core_ctl/enable
echo "0" > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo "3" > /sys/devices/system/cpu/cpu4/core_ctl/max_cpus
echo "633600" > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
echo "2496000" > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy4/walt/adaptive_high_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy4/walt/adaptive_low_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy4/walt/boost

echo "1" > /sys/devices/system/cpu/cpu7/core_ctl/enable
echo "0" > /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
echo "1" > /sys/devices/system/cpu/cpu7/core_ctl/max_cpus
echo "806400" > /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq
echo "2995200" > /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy7/walt/adaptive_high_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy7/walt/adaptive_low_freq
echo "1" > /sys/devices/system/cpu/cpufreq/policy7/walt/boost