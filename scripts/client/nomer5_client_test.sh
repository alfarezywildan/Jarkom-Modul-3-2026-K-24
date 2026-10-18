#!/bin/sh
# ==============================================================
# Soal 5: Uji Coba Lease Time & Opsi DHCP pada Client Network 3
# Node Target: ino, kusakabe, miwa
# Lokasi     : /root/nomer5_client_test.sh
# 
# Verifikasi:
# - ino & kusakabe : Short Lease 1800 detik (30m), Pool 192.223.3.10 - 192.223.3.89
# - miwa           : Long Lease 43200 detik (12h), Pool 192.223.3.100 - 192.223.3.199
# - DNS Resolvers  : 192.223.1.2 dan 192.223.1.3
# - Domain Search  : K24.com
# ==============================================================

echo "=========================================================="
echo "[*] [1] Melepaskan Alamat IP Lama pada eth0..."
echo "=========================================================="
ip addr flush dev eth0

echo "=========================================================="
echo "[*] [2] Meminta Lease Baru dengan Mode Verbose (Cek Lease Time)..."
echo "=========================================================="
udhcpc -i eth0 -n -q

echo ""
echo "=========================================================="
echo "[*] [3] Status Alamat IP pada eth0:"
echo "=========================================================="
ip -br a show dev eth0
ip addr show dev eth0

echo ""
echo "=========================================================="
echo "[*] [4] Tabel Routing Default Gateway:"
echo "=========================================================="
ip route show

echo ""
echo "=========================================================="
echo "[*] [5] Isi File /etc/resolv.conf (DNS & Domain Search):"
echo "=========================================================="
cat /etc/resolv.conf

GW=$(ip route show default | awk '{print $3}')
if [ -n "$GW" ]; then
    echo ""
    echo "=========================================================="
    echo "[*] [6] Uji Ping Gateway ($GW):"
    echo "=========================================================="
    ping -c 2 -W 2 "$GW"
fi

echo ""
echo "=========================================================="
echo "[*] [7] Uji Ping Internet (8.8.8.8):"
echo "=========================================================="
ping -c 2 -W 2 8.8.8.8
