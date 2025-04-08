#!/system/bin/xbin/busybox sh
# file descriptor limit
echo "1048576" > /proc/sys/fs/file-max
echo "1048576" > /proc/sys/fs/nr_open

# IPCore
echo "4096" > /proc/sys/net/core/somaxconn
echo "16777216" > /proc/sys/net/core/wmem_max
echo "16777216" > /proc/sys/net/core/rmem_max
echo "50000" > /proc/sys/net/core/netdev_max_backlog
echo "20480" > /proc/sys/net/core/optmem_max
echo "32" > /proc/sys/net/core/max_skb_frags

# IPv4
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "20" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "1200" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo "1024" > /proc/sys/net/ipv4/tcp_max_syn_backlog
echo "1" > /proc/sys/net/ipv4/tcp_fastopen
echo "1" > /proc/sys/net/ipv4/tcp_timestamps
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_fack
echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 16777216" > /proc/sys/net/ipv4/tcp_wmem
echo "10240 65535" > /proc/sys/net/ipv4/ip_local_port_range
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "0" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "16384" > /proc/sys/net/ipv4/tcp_max_tw_buckets
echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling

# IPv6
echo "1" > /proc/sys/net/ipv6/conf/all/enable
echo "0" > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo "0" > /proc/sys/net/ipv6/conf/all/accept_ra
echo "0" > /proc/sys/net/ipv6/conf/default/accept_ra
echo "1" > /proc/sys/net/ipv6/conf/all/forwarding
echo "1" > /proc/sys/net/ipv6/conf/all/accept_redirects
echo "1" > /proc/sys/net/ipv6/conf/all/accept_source_route
echo "1" > /proc/sys/net/ipv6/conf/all/rcvbuf
echo "1" > /proc/sys/net/ipv6/conf/all/sndbuf
echo "1" > /proc/sys/net/ipv6/conf/all/mtu_discovery
echo "60" > /proc/sys/net/ipv6/neigh/default/gc_stale_time
echo "120" > /proc/sys/net/ipv6/neigh/default/base_reachable_time_ms
echo "0" > /proc/sys/net/ipv6/conf/all/flowlabel_state_ranges
echo "10240 65535" > /proc/sys/net/ipv6/ip_local_port_range
echo "1" > /proc/sys/net/ipv6/tcp_window_scaling
echo "1" > /proc/sys/net/ipv6/tcp_fastopen
echo "1" > /proc/sys/net/ipv6/tcp_syncookies
echo "1200" > /proc/sys/net/ipv6/tcp_keepalive_time
echo "15" > /proc/sys/net/ipv6/tcp_keepalive_intvl
echo "9" > /proc/sys/net/ipv6/tcp_keepalive_probes
echo "10" > /proc/sys/net/ipv6/tcp_init_cwnd
echo "1440" > /proc/sys/net/ipv6/tcp_mtu_probing
echo "1280" > /proc/sys/net/ipv6/tcp_base_mss
echo "1" > /proc/sys/net/ipv6/tcp_timestamps
echo "1" > /proc/sys/net/ipv6/tcp_sack
echo "1" > /proc/sys/net/ipv6/tcp_fack
echo "1" > /proc/sys/net/ipv6/tcp_ecn
echo "bbr" > /proc/sys/net/ipv6/tcp_congestion_control
echo "1000" > /proc/sys/net/ipv6/icmp/ratelimit
echo "3" > /proc/sys/net/ipv6/neigh/default/unres_qlen

Function=0

if [[ "${Function}" == "0" ]]; then
    echo "######### File=Network.sh $(date) #########" >>${ServiceLog}
    MTU=1500
    TxQueueLen=100

    #循环获取接口
    for NetworkInterface in /sys/class/net/*; do
        echo "---------------------------------------------" >>${ServiceLog}
        #获取接口名
        NetworkInterfaceName=${NetworkInterface##*/}
        ifconfig ${NetworkInterfaceName} up >>${ServiceLog}
        ifconfig ${NetworkInterfaceName} mtu ${MTU} >>${ServiceLog}
        ifconfig ${NetworkInterfaceName} txqueuelen ${TxQueueLen} >>${ServiceLog}
    done
    iptables -4 -w -t filter -F tetherctrl_FORWARD
    iptables -4 -w -t filter -A tetherctrl_FORWARD -j bw_global_alert
    iptables -4 -w -t filter -A tetherctrl_FORWARD -g tetherctrl_counters
    iptables -4 -w -t filter -A tetherctrl_FORWARD -j DROP
    iptables -4 -w -t mangle -F tetherctrl_mangle_FORWARD

    ip6tables -6 -w -t filter -F tetherctrl_FORWARD
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -j bw_global_alert
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -g tetherctrl_counters
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -j DROP
    ip6tables -6 -w -t mangle -F tetherctrl_mangle_FORWARD

    settings put global mobile_data_always_on 1
    echo 1 >/proc/sys/net/ipv4/conf/all/forwarding
    echo 1 >/proc/sys/net/ipv6/conf/all/forwarding

else
    function CheckIPAddress() {
        CheckIPAddress_IPType=${1}
        CheckIPAddress_IPAddress=${2}
        if [[ ${CheckIPAddress_IPType} == "IPv4" ]]; then
    2        if [[ -z ${CheckIPAddress_IPAddress} ]]; then
                return 1
            fi
            if [[ ${CheckIPAddress_IPAddress} == 127.* ]]; then
                return 1
            fi
            if [[ ${CheckIPAddress_IPAddress} == 192.168.43.* ]]; then
                return 1
            fi
        fi
        if [[ ${CheckIPAddress_IPType} == "IPv6" ]]; then
            if [[ -z ${CheckIPAddress_IPAddress} ]]; then
                return 1
            fi
            if [[ ${CheckIPAddress_IPAddress} == fe80:* ]]; then
                return 1
            fi
            if [[ ${CheckIPAddress_IPAddress} == ::* ]]; then
                return 1
            fi
        fi

        return 0
    }
    function CheckNetworkInterfacePing() {
        CheckNetworkInterfacePing_InterfaceName=${1}
        CheckNetworkInterfacePing_IPType=${2}
        CheckNetworkInterfacePing_IPServer=${3}

        GettingIPAddress_PingType=""
        if [[ ${CheckNetworkInterfacePing_IPType} == "IPv4" ]]; then
            GettingIPAddress_PingType="ping"
        fi
        if [[ ${CheckNetworkInterfacePing_IPType} == "IPv6" ]]; then
            GettingIPAddress_PingType="ping6"
        fi
        if ${GettingIPAddress_PingType} -I ${CheckNetworkInterfacePing_InterfaceName} -c 4 -W 4 ${CheckNetworkInterfacePing_IPServer} >/dev/null; then
            return 0
        else
            return 1
        fi
    }

    echo "######### File=Network.sh $(date) #########" >>${ServiceLog}
    rt_tables=/data/misc/net/rt_tables
    Lock="/dev/var/run/${ServiceName}.Network.Lock"
    Pref=1000
    if [ ! -f ${Lock} ]; then
        echo IPv4Interface= >>${Lock}
        echo IPv6Interface= >>${Lock}

        ip -4 rule add from all lookup main pref ${Pref}
        ip -6 rule add from all lookup main pref ${Pref}

        settings put global mobile_data_always_on 1

        echo 1 >/proc/sys/net/ipv4/conf/all/forwarding
        echo 1 >/proc/sys/net/ipv6/conf/all/forwarding

    fi

    MTU=1500
    TxQueueLen=100

    IPv4Server=1.2.4.8
    IPv6Server=240C::6666

    IPv4Mark=1
    IPv4Every=2
    IPv4Packet=0
    IPv4Probability=0.5
    IPv4Index=1

    IPv6Mark=1
    IPv6Every=2
    IPv6Packet=0
    IPv6Probability=0.5
    IPv6Index=1

    iptables -4 -w -t filter -N FORWARD_NETWORK || true
    iptables -4 -w -t filter -F FORWARD_NETWORK

    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10063/0x1ffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10063/0x1ffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0001/0xdffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0001/0xdffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0066/0xdffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0066/0xdffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10065/0x1ffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10065/0x1ffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x50064/0x5ffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x50064/0x5ffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xd0000 -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xd0000 -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xc0000 -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xc0000 -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x40000/0x40000 -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x40000/0x40000 -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0x10000 -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0x10000 -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x65/0x1fff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x65/0x1fff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0xffff -j ACCEPT
    iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0xffff -j MARK --set-mark 0
    #iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -j ACCEPT

    ip6tables -6 -w -t filter -N FORWARD_NETWORK || true
    ip6tables -6 -w -t filter -F FORWARD_NETWORK

    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10063/0x1ffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10063/0x1ffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0001/0xdffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0001/0xdffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0066/0xdffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xd0066/0xdffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10065/0x1ffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x10065/0x1ffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x50066/0x5ffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x50066/0x5ffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xd0000 -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xd0000 -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xc0000 -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0xc0000/0xc0000 -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x60000/0x60000 -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x60000/0x60000 -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0x10000 -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0x10000 -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x65/0x1fff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x65/0x1fff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0xffff -j ACCEPT
    ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0x0/0xffff -j MARK --set-mark 0
    #ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -j ACCEPT

    #循环获取接口
    for NetworkInterface in /sys/class/net/*; do
        echo "---------------------------------------------" >>${ServiceLog}
        #获取接口名
        NetworkInterfaceName=${NetworkInterface##*/}
        #ifconfig ${NetworkInterfaceName} up >>${ServiceLog}
        ifconfig ${NetworkInterfaceName} mtu ${MTU} >>${ServiceLog}
        ifconfig ${NetworkInterfaceName} txqueuelen ${TxQueueLen} >>${ServiceLog}

        IPv4GatewayAddress=$(ip -4 route list table 0 | grep "default.*${NetworkInterfaceName}" | awk '{print $3}')
        IPv4Address=$(ip -4 addr show ${NetworkInterfaceName} | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        if CheckIPAddress "IPv4" ${IPv4Address}; then
            if CheckNetworkInterfacePing ${NetworkInterfaceName} "IPv4" ${IPv4Server}; then
                if sed -n "1p" ${Lock} | grep -q ${NetworkInterfaceName}; then
                    echo "[!] ${NetworkInterfaceName} IPv4 Lock 1" >>${ServiceLog}
                else
                    existing_rules=$(iptables -4 -t filter -S OUTPUT | grep " -o ${NetworkInterfaceName} ")
                    if [ ! -z "${existing_rules}" ]; then
                        echo "[!] ${NetworkInterfaceName} IPv4 Exists" >>${ServiceLog}
                    else
                        iptables -t filter -I OUTPUT ${IPv4Index} -o ${NetworkInterfaceName} -j MARK --set-mark 0
                        iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -m statistic --mode nth --every ${IPv4Every} --packet ${IPv4Packet} -j MARK --set-mark ${IPv4Mark} >>${ServiceLog}
                        iptables -4 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -m statistic --mode random --probability ${IPv4Probability} -j MARK --set-mark ${IPv4Mark} >>${ServiceLog}
                    fi
                    sed -i "1s|$|${NetworkInterfaceName},${IPv4Mark},${IPv4GatewayAddress},${IPv4Address};|" ${Lock} >>${ServiceLog}
                    echo "[*] ${NetworkInterfaceName} IPv4 Lock 0" >>${ServiceLog}
                fi
                let IPv4Mark+=1
                let IPv4Every+=1
                let IPv4Packet+=1
                let IPv4Index+=2
            else
                sed -i "1s/${NetworkInterfaceName},[^;],[^;],[^;];*//" ${Lock}
                echo "[x] ${NetworkInterfaceName} IPv4 Ping 1" >>${ServiceLog}
            fi
        else
            echo "[x] ${NetworkInterfaceName} IPv4Address Check 1" >>${ServiceLog}
        fi

        IPv6GatewayAddress=$(ip -6 route list table 0 | grep "default.*${NetworkInterfaceName}" | awk '{print $3}')
        IPv6Address=$(ip -6 addr show ${NetworkInterfaceName} | grep "inet6" | awk '{print $2}' | cut -d/ -f1)
        if CheckIPAddress "IPv6" ${IPv6Address}; then
            if CheckNetworkInterfacePing ${NetworkInterfaceName} "IPv6" ${IPv6Server}; then
                if sed -n "2p" ${Lock} | grep -q ${NetworkInterfaceName}; then
                    echo "[!] ${NetworkInterfaceName} IPv6 Lock 1" >>${ServiceLog}
                else
                    existing_rules=$(ip6tables -6 -t filter -S OUTPUT | grep " -o ${NetworkInterfaceName} ")
                    if [ ! -z "${existing_rules}" ]; then
                        echo "[!] ${NetworkInterfaceName} IPv6 Exists" >>${ServiceLog}
                    else
                        ip6tables -t filter -I OUTPUT ${IPv6Index} -o ${NetworkInterfaceName} -j MARK --set-mark 0
                        ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -m statistic --mode nth --every ${IPv6Every} --packet ${IPv6Packet} -j MARK --set-mark ${IPv6Mark} >>${ServiceLog}
                        ip6tables -6 -w -t filter -A FORWARD_NETWORK -m mark --mark 0 -m statistic --mode random --probability ${IPv6Probability} -j MARK --set-mark ${IPv6Mark} >>${ServiceLog}
                    fi
                    sed -i "2s|$|${NetworkInterfaceName},${IPv6Mark},${IPv6GatewayAddress},${IPv6Address};|" ${Lock} >>${ServiceLog}
                    echo "[*] ${NetworkInterfaceName} IPv6 Lock 0" >>${ServiceLog}
                fi
                let IPv6Mark+=1
                let IPv6Every+=1
                let IPv6Packet+=1
                let IPv6Index+=2
            else
                sed -i "2s/${NetworkInterfaceName},[^;],[^;],[^;];*//" ${Lock}
                echo "[x] ${NetworkInterfaceName} IPv6 Ping 1" >>${ServiceLog}
            fi
        else
            echo "[x] ${NetworkInterfaceName} IPv6Address Check 1" >>${ServiceLog}
        fi
    done
    #HotspotInterface=$(ifconfig -a | grep -E 'wlan2|wlan3|ap_br_wlan2' | awk '{print$1}')
    HotspotInterface=ap_br_wlan2

    OldGatewayAddress=""

    echo "------------- IPv4 Setting Mark -------------" >>${ServiceLog}
    HotspotInterfaceAddress=$(ip -4 addr show ${HotspotInterface} | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    ipv4mark=$((${IPv4Mark} - 1))
    pref=$((${Pref} + 1))
    LockFileInterfaceLine=$(sed -n "1p" ${Lock})
    LockInterface=$(echo ${LockFileInterfaceLine} | awk -F '=' '{print $2}')
    LockInterfaceName=$(echo ${LockInterface} | sed 's/;/\n/g')
    #iptables -4 -w -t filter -D FORWARD -j tetherctrl_FORWARD
    #iptables -4 -w -t filter -A FORWARD -j tetherctrl_FORWARD

    iptables -4 -w -t filter -F tetherctrl_FORWARD
    iptables -4 -w -t filter -A tetherctrl_FORWARD -j bw_global_alert
    iptables -4 -w -t filter -A tetherctrl_FORWARD -g FORWARD_NETWORK
    iptables -4 -w -t filter -A tetherctrl_FORWARD -g tetherctrl_counters
    iptables -4 -w -t filter -A tetherctrl_FORWARD -j DROP

    for Interface in ${LockInterfaceName}; do
        InterfaceName=$(echo ${Interface} | cut -d ',' -f 1)
        Mark=$(echo ${Interface} | cut -d ',' -f 2)
        GatewayAddress=$(echo ${Interface} | cut -d ',' -f 3)
        IPAddress=$(echo ${Interface} | cut -d ',' -f 4)
        echo "------------- ${InterfaceName} -------------" >>${ServiceLog}
        echo "[!] IPv4Interface:${InterfaceName} IP4Mark=${ipv4mark} Mark=${Mark}" >>${ServiceLog}
        ipmark=1
        while [ "${ipmark}" -le "${ipv4mark}" ]; do
            if [ "${ipmark}" == "${Mark}" ]; then
                echo "[x] IPv4Interface:${InterfaceName}:ipmark=${ipmark}==Mark=${Mark}" >>${ServiceLog}
                ip -4 rule del pref ${pref}
                ip -4 rule add from ${IPAddress}/32 lookup main pref ${pref}
                ip -4 route add ${IPAddress}/32 dev ${HotspotInterface} src ${HotspotInterfaceAddress}
                TableID=$(cat ${rt_tables} | grep "${InterfaceName}" | awk '{print $1}')
                ip -4 rule add dev ${HotspotInterface} pref 21000 from all iif ${HotspotInterface} lookup ${TableID}
                ip -4 route add ${HotspotInterfaceAddress}/32 dev ${InterfaceName} metric 0
                ip -4 route flush cache
                let pref+=1
            else
                iptables -4 -w -t filter -A FORWARD_NETWORK -i ${InterfaceName} -o ${HotspotInterface} -m state --state ESTABLISHED,RELATED -g tetherctrl_counters
                iptables -4 -w -t filter -A FORWARD_NETWORK -i ${InterfaceName} -o ${HotspotInterface} -j ACCEPT
                #iptables -4 -w -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m state --state INVALID -j DROP
                #iptables -4 -w  -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -g tetherctrl_counters >>${ServiceLog} 2>&1

                iptables -4 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -g tetherctrl_counters
                iptables -4 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -j ACCEPT
                iptables -4 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark 0 -j ACCEPT
                #iptables -4 -w -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m ttl --ttl-lt 2 -j DROP
            fi
            existing_rules=$(iptables -4 -S tetherctrl_counters | grep " -i ${InterfaceName} ")
            if [ ! -z "${existing_rules}" ]; then
                echo "[!] ${NetworkInterfaceName} IPv4 Exists" >>${ServiceLog}
            else
                iptables -4 -w -t filter -A tetherctrl_counters -p all -i ${InterfaceName} -o ${HotspotInterface} -j RETURN
                iptables -4 -w -t filter -A tetherctrl_counters -p all -i ${HotspotInterface} -o ${InterfaceName} -j RETURN
            fi
            echo "[*] IPv4Interface:${InterfaceName}:ipmark=${ipmark}:Mark=${Mark}" >>${ServiceLog}
            ipmark=$((ipmark + 1))
        done
    done

    echo "------------- IPv6 Setting Mark -------------" >>${ServiceLog}
    HotspotInterfaceAddress=$(ip -6 addr show ${HotspotInterface} | grep "inet6" | awk '{print $2}' | cut -d/ -f1)
    ipv6mark=$((${IPv6Mark} - 1))
    pref=$((${Pref} + 1))
    LockFileInterfaceLine=$(sed -n "2p" ${Lock})
    LockInterface=$(echo ${LockFileInterfaceLine} | awk -F '=' '{print $2}')
    LockInterfaceName=$(echo ${LockInterface} | sed 's/;/\n/g')
    #ip6tables -6 -w -t filter -D FORWARD -j tetherctrl_FORWARD
    #ip6tables -6 -w -t filter -A FORWARD -j tetherctrl_FORWARD

    ip6tables -6 -w -t filter -F tetherctrl_FORWARD
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -j bw_global_alert
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -g FORWARD_NETWORK
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -g tetherctrl_counters
    ip6tables -6 -w -t filter -A tetherctrl_FORWARD -j DROP

    for Interface in ${LockInterfaceName}; do
        InterfaceName=$(echo ${Interface} | cut -d ',' -f 1)
        Mark=$(echo ${Interface} | cut -d ',' -f 2)
        GatewayAddress=$(echo ${Interface} | cut -d ',' -f 3)
        IPAddress=$(echo ${Interface} | cut -d ',' -f 4)
        echo "------------- ${InterfaceName} -------------" >>${ServiceLog}
        echo "[!] IPv6Interface:${InterfaceName} IP6Mark=${ipv6mark} Mark=${Mark}" >>${ServiceLog}
        ipmark=1
        while [ "${ipmark}" -le "${ipv6mark}" ]; do
            if [ "${ipmark}" == "${Mark}" ]; then
                echo "[x] IPv6Interface:${InterfaceName}:ipmark=${ipmark}==Mark=${Mark}" >>${ServiceLog}
                ip -6 rule del pref ${pref}
                ip -6 rule add from ${IPAddress}/128 lookup main pref ${Pref}
                ip -6 route add ${IPAddress}/128 dev ${HotspotInterface} src ${HotspotInterfaceAddress}
                TableID=$(cat ${rt_tables} | grep "${InterfaceName}" | awk '{print $1}')
                ip -6 rule add dev ${HotspotInterface} pref 21000 from all iif ${HotspotInterface} lookup ${TableID}
                ip -6 route add ${HotspotInterfaceAddress}/32 dev ${InterfaceName} metric 0
                let pref+=1
            else
                ip6tables -6 -w -t filter -A FORWARD_NETWORK -i ${InterfaceName} -o ${HotspotInterface} -m state --state ESTABLISHED,RELATED -g tetherctrl_counters
                ip6tables -6 -w -t filter -A FORWARD_NETWORK -i ${InterfaceName} -o ${HotspotInterface} -j ACCEPT
                #ip6tables -6 -w -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m state --state INVALID -j DROP
                #ip6tables -6 -w  -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -g tetherctrl_counters >>${ServiceLog} 2>&1
                ip6tables -6 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -g tetherctrl_counters
                ip6tables -6 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark ${ipmark} -j ACCEPT
                ip6tables -6 -w -t filter -A FORWARD_NETWORK -i ${HotspotInterface} -o ${InterfaceName} -m mark --mark 0 -j ACCEPT
                #ip6tables -6 -w -t filter -A tetherctrl_FORWARD -i ${HotspotInterface} -o ${InterfaceName} -m ttl --ttl-lt 2 -j DROP
            fi
            existing_rules=$(ip6tables -6 -S tetherctrl_counters | grep " -i ${InterfaceName} ")
            if [ ! -z "${existing_rules}" ]; then
                echo "[!] ${NetworkInterfaceName} IPv6 Exists" >>${ServiceLog}
            else
                ip6tables -6 -w -t filter -A tetherctrl_counters -p all -i ${InterfaceName} -o ${HotspotInterface} -j RETURN
                ip6tables -6 -w -t filter -A tetherctrl_counters -p all -i ${HotspotInterface} -o ${InterfaceName} -j RETURN
            fi
            echo "[*] IPv6Interface:${InterfaceName}:ipmark=${ipmark}:Mark=${Mark}" >>${ServiceLog}
            ipmark=$((ipmark + 1))
        done
    done
#ip6tables -6 -w -t filter -A FORWARD_NETWORK -g tetherctrl_counters
    RouteTableFile=/data/misc/net/rt_tables
    IPRouteTableWlan0=$(cat ${RouteTableFile} | grep "wlan0" | awk '{print $1}')
    IPRouteTableWlan2=$(cat ${RouteTableFile} | grep "wlan2" | awk '{print $1}')
    ip -4 route list | awk '{print $3}' | sort -u | while read NetworkInterfaceName; do
    IPRouteTableValue=$(cat ${RouteTableFile} | grep "${NetworkInterfaceName}" | awk '{print $1}')
    if[[ ${IPRouteTableValue} != ${IPRouteTableWlan0} ]]; then
    if[[ ${IPRouteTableValue} != ${IPRouteTableWlan2} ]]; then
    IPv4RouteGatewayAddress=$(ip -4 route list table 0 | grep "default.*${NetworkInterfaceName}" | awk '{print $3}')
    IPv4RouteAddress=$(ip -4 route list | grep "${NetworkInterfaceName}" | awk '{print $1}')
    ip -4 route flush table ${IPRouteTableValue}
    ip -4 route add default via ${IPv4RouteGatewayAddress} dev ${NetworkInterfaceName} proto static mtu ${MTU}
    ip -4 route add ${IPv4RouteAddress} dev ${NetworkInterfaceName} proto static scope link
    ip -4 route add ${IPv4RouteAddress} dev ${NetworkInterfaceName} proto static scope link table ${IPRouteTableWlan0}
    fi
    fi
    done
    ip -6 route list table 0 | grep -v -e '^fe80::/64' -e 'default' | awk '{print $3}' | sort -u | while read NetworkInterfaceName; do
    IPRouteTableValue=$(cat ${RouteTableFile} | grep "${NetworkInterfaceName}" | awk '{print $1}')
    if[[ ${IPRouteTableValue} != ${IPRouteTableWlan0} ]]; then
    if[[ ${IPRouteTableValue} != ${IPRouteTableWlan2} ]]; then
    IPv6RouteGatewayAddress=$(ip -6 route list table 0 | grep "default.*${NetworkInterfaceName}" | awk '{print $3}')
    IPv6RouteAddress=$(ip -6 route list table ${IPRouteTableValue} | grep -w "dev ${NetworkInterfaceName}" | awk '{print $1}' | grep -v -e '^fe80::/' -e 'default' | sort -u)
    IPv6RouteAddressLocal=$(ip -6 route list table ${IPRouteTableValue} | grep -w "dev ${NetworkInterfaceName}" | awk '{print $1}' | grep -v -e '^240e:' -e 'default' | sort -u)
    ip -6 route flush table ${IPRouteTableValue}
    ip -6 route flush table 0
    ip -6 route add default via ${IPv6RouteGatewayAddress} dev ${NetworkInterfaceName} proto ra metric 1024 expires 53734sec hoplimit 255 pref medium
    ip -6 route add ${IPv6RouteAddress} dev ${NetworkInterfaceName} proto kernel metric 256 pref medium
    ip -6 route add ${IPv6RouteAddress} dev ${NetworkInterfaceName} proto kernel metric 256 pref medium table 0
    ip -6 route add ${IPv6RouteAddress} dev ${NetworkInterfaceName} proto static metric 1024 pref medium
    ip -6 route add ${IPv6RouteAddress} dev ${NetworkInterfaceName} proto static metric 1024 pref medium table 0
    ip -6 route add ${IPv6RouteAddressLocal} dev ${NetworkInterfaceName} proto kernel metric 256 pref medium
    ip -6 route add ${IPv6RouteAddressLocal} dev ${NetworkInterfaceName} proto kernel metric 256 pref medium table 0
    ip -6 route add ${IPv6RouteAddress} dev ${NetworkInterfaceName} proto static metric 256 pref medium table ${IPRouteTableWlan0}
    fi
    fi
    done
fi
