#!/bin/sh
# ==============================================================
# Soal 7: Verifikasi Menyeluruh Konfigurasi Jaringan & Routing
# Node Target: Seluruh Client Divisi A & B (8 Client)
# Lokasi     : /root/nomer7_client_test.sh
# 
# Pengecekan:
# 1. IP Address & Subnet Mask /24 (255.255.255.0)
# 2. Broadcast Address (.255)
# 3. Default Gateway (192.223.2.1 / 192.223.3.1)
# 4. DNS Resolvers (192.223.1.2 & 192.223.1.3) & Search K24.com
# 5. Ping Gateway & Internet (8.8.8.8)
# ==============================================================

echo "=== [1] FLUSH & REQUEST LEASE ==="
ip addr flush dev eth0
udhcpc -i eth0 -n -q

echo "=== [2] IP & BROADCAST ==="
ip -br a show dev eth0
ip addr show dev eth0

echo "=== [3] ROUTING ==="
ip route show

echo "=== [4] DNS & SEARCH ==="
cat /etc/resolv.conf

echo "=== [5] PING GATEWAY ==="
GW=$(ip route show default | awk '{print $3}')
if [ -n "$GW" ]; then
    ping -c 2 -W 2 "$GW"
else
    echo "[-] Default Gateway tidak ditemukan!"
fi

echo "=== [6] PING INTERNET ==="
ping -c 2 -W 2 8.8.8.8
