#!/bin/bash
# ==============================================================
# Soal 1: Konfigurasi IP Statis & Gateway pada Server tengen
# Node Target: tengen
# Lokasi     : /root/nomer1_tengen.sh
# ==============================================================

echo "[*] Mengatur IP Address dan Default Route pada tengen..."

# 1. Interface eth0 terhubung ke switch Data Center (Network 4)
ip addr add 192.223.4.10/24 dev eth0 2>/dev/null
ip link set eth0 up

# 2. Default route melalui interface eth4 router jichi
ip route replace default via 192.223.4.1

# 3. DNS Resolver WAN
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "[+] Konfigurasi tengen selesai. Status Interface:"
ip -br a
