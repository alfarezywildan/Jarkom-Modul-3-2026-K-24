#!/bin/sh
# ==============================================================
# Soal 3: Uji Coba Penerimaan Lease melalui DHCP Relay
# Node Target: Client Network 2 (itadori) / Network 3 (ino)
# Lokasi     : /root/nomer3_client_test.sh
# ==============================================================

echo "=========================================================="
echo "[*] [1] Melepaskan Alamat IP Lama pada eth0..."
echo "=========================================================="
ip addr flush dev eth0

echo "=========================================================="
echo "[*] [2] Meminta Lease Baru ke DHCP Server via Relay..."
echo "=========================================================="
udhcpc -i eth0 -n -q
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "[+] Berhasil memperoleh konfigurasi DHCP melalui relay!"
else
    echo "[-] Gagal memperoleh lease melalui relay (timeout)!"
fi

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
