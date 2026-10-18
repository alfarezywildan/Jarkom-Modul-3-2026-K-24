#!/bin/sh
# ==============================================================
# Soal 6: Uji Coba Static Lease (VIP kugisaki) & Uji Isolasi
# Node Target: kugisaki (dan klien pembanding seperti ino)
# Lokasi     : /root/nomer6_client_test.sh
# 
# Verifikasi:
# - kugisaki : Mendapatkan fixed address 192.223.3.99/24
# - Klien lain: Tidak boleh mendapatkan 192.223.3.99 (terisolasi)
# ==============================================================

HOSTNAME=$(hostname)
echo "=========================================================="
echo "[*] [1] Node: $HOSTNAME - Melepaskan IP lama pada eth0..."
echo "=========================================================="
ip addr flush dev eth0

echo "=========================================================="
echo "[*] [2] Menjalankan udhcpc untuk meminta lease..."
echo "=========================================================="
udhcpc -i eth0 -n -q

echo ""
echo "=========================================================="
echo "[*] [3] Status Alamat IP pada eth0:"
echo "=========================================================="
ip -br a show dev eth0
ip addr show dev eth0

ASSIGNED_IP=$(ip -4 addr show dev eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "[*] Alamat IP terdeteksi: $ASSIGNED_IP"

if [ "$HOSTNAME" = "kugisaki" ]; then
    if [ "$ASSIGNED_IP" = "192.223.3.99" ]; then
        echo "[+] SUKSES: kugisaki menerima Fixed VIP Address 192.223.3.99!"
    else
        echo "[-] PERINGATAN: kugisaki menerima $ASSIGNED_IP (Diharapkan 192.223.3.99)!"
    fi
else
    if [ "$ASSIGNED_IP" = "192.223.3.99" ]; then
        echo "[-] PELANGGARAN: Node $HOSTNAME mendapatkan IP VIP 192.223.3.99!"
    else
        echo "[+] SUKSES: Node $HOSTNAME tidak mengambil IP VIP (Terisolasi Sempurna)."
    fi
fi

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
