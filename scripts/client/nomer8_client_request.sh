#!/bin/sh
# ==============================================================
# Soal 8: Memicu Request DHCP untuk Analisis Packet Capture
# Node Target: Client Network 2 (itadori) / Network 3 (ino)
# Lokasi     : /root/nomer8_client_request.sh
# ==============================================================

echo "=========================================================="
echo "[*] [1] Melepaskan Konfigurasi IP Lama pada eth0..."
echo "=========================================================="
ip addr flush dev eth0

echo "=========================================================="
echo "[*] [2] Mengirim DHCP Discover Baru via udhcpc..."
echo "=========================================================="
udhcpc -i eth0 -n -q

echo ""
echo "=========================================================="
echo "[*] [3] Konfigurasi Interface eth0 Saat Ini:"
echo "=========================================================="
ip -br a show dev eth0
ip addr show dev eth0

echo ""
echo "[+] Permintaan lease selesai. Periksa tangkapan paket di server tengen."
