#!/bin/sh
# ==============================================================
# Soal 10: Skrip Verifikasi Pasca Restart pada Klien
# Node Target: Seluruh Client Divisi A & B
# Lokasi     : /root/nomer10_client_verify.sh
# ==============================================================

echo "=========================================================="
echo "[*] [1] Melepaskan Konfigurasi Lama & Meminta Ulang Lease..."
echo "=========================================================="
ip addr flush dev eth0
udhcpc -i eth0 -n -q

echo ""
echo "=========================================================="
echo "[*] [2] Parameter Jaringan yang Diperoleh:"
echo "=========================================================="
ip -br a show dev eth0
ip addr show dev eth0

echo ""
echo "=========================================================="
echo "[*] [3] Tabel Routing Default Gateway:"
echo "=========================================================="
ip route show

echo ""
echo "=========================================================="
echo "[*] [4] Konfigurasi DNS Resolver (/etc/resolv.conf):"
echo "=========================================================="
cat /etc/resolv.conf

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
