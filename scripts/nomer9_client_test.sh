#!/bin/sh
# ==============================================================
# Soal 9: Uji Coba Gejala Gangguan & Pemulihan pada Client
# Node Target: Client Network 2 (itadori) / Network 3 (ino)
# Lokasi     : /root/nomer9_client_test.sh
# ==============================================================

echo "=========================================================="
echo "=== [1] FLUSH & REQUEST LEASE ==="
echo "=========================================================="
ip addr flush dev eth0
udhcpc -i eth0 -n -q
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "[-] GAGAL MEMPEROLEH LEASE DARI DHCP SERVER (Relay Terputus / Outage Terkonfirmasi)"
else
    echo "[+] BERHASIL MEMPEROLEH LEASE DARI DHCP SERVER (Relay Berfungsi / Recovery Terkonfirmasi)"
fi

echo ""
echo "=========================================================="
echo "=== [2] STATUS ALAMAT IP ==="
echo "=========================================================="
ip -br a show dev eth0
ip a show dev eth0 | grep "inet " || echo "[-] Tidak ada alamat IPv4 yang terpasang."

echo ""
echo "=========================================================="
echo "=== [3] ROUTING TABLE ==="
echo "=========================================================="
ip route show

echo ""
echo "=========================================================="
echo "=== [4] DNS & SEARCH (/etc/resolv.conf) ==="
echo "=========================================================="
cat /etc/resolv.conf 2>/dev/null

echo ""
echo "=========================================================="
echo "=== [5] PING GATEWAY ==="
echo "=========================================================="
GW=$(ip route show default | awk '{print $3}')
if [ -n "$GW" ]; then
    ping -c 2 -W 2 "$GW"
else
    echo "[-] Ping Gateway GAGAL: default route tidak ada (Network unreachable)."
fi

echo ""
echo "=========================================================="
echo "=== [6] PING INTERNET ==="
echo "=========================================================="
ping -c 2 -W 2 8.8.8.8 || echo "[-] Ping Internet GAGAL: Akses keluar terputus."
