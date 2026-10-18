#!/bin/sh
# ==============================================================
# Soal 4: Uji Coba Alokasi Pool DHCP Client Network 2 (Divisi A)
# Node Target: itadori, fushiguro, zenin, okkotsu
# Lokasi     : /root/nomer4_client_test.sh
# 
# Verifikasi:
# - itadori & fushiguro  -> Pool 1 (192.223.2.10 - 192.223.2.35)
# - zenin & okkotsu      -> Pool 2 (192.223.2.70 - 192.223.2.95)
# ==============================================================

echo "=========================================================="
echo "[*] [1] Melepaskan Alamat IP Lama pada eth0..."
echo "=========================================================="
ip addr flush dev eth0

echo "=========================================================="
echo "[*] [2] Meminta Lease Baru dari DHCP Server..."
echo "=========================================================="
udhcpc -i eth0 -n -q

echo ""
echo "=========================================================="
echo "[*] [3] Alamat IP dan Interface yang Diperoleh:"
echo "=========================================================="
ip -br a show dev eth0
ip addr show dev eth0

echo ""
echo "=========================================================="
echo "[*] [4] Tabel Routing Default Gateway:"
echo "=========================================================="
ip route show

GW=$(ip route show default | awk '{print $3}')
if [ -n "$GW" ]; then
    echo ""
    echo "=========================================================="
    echo "[*] [5] Uji Ping Gateway ($GW):"
    echo "=========================================================="
    ping -c 2 -W 2 "$GW"
fi

echo ""
echo "=========================================================="
echo "[*] [6] Uji Ping Internet (8.8.8.8):"
echo "=========================================================="
ping -c 2 -W 2 8.8.8.8
