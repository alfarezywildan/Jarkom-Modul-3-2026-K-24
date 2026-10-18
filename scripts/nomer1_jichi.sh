#!/bin/bash
# ==============================================================
# Soal 1: Konfigurasi Interface Jaringan & NAT pada Router jichi
# Node Target: jichi
# Lokasi     : /root/nomer1_jichi.sh
# ==============================================================

echo "[*] Mengatur IP Address Interface pada jichi..."

# 1. Interface WAN terhubung ke NAT (eth0)
ip addr add 192.168.122.20/24 dev eth0 2>/dev/null
ip link set eth0 up
ip route replace default via 192.168.122.1

# 2. Interface LAN Internal (eth1 - eth4)
ip addr add 192.223.1.1/24 dev eth1 2>/dev/null && ip link set eth1 up
ip addr add 192.223.2.1/24 dev eth2 2>/dev/null && ip link set eth2 up
ip addr add 192.223.3.1/24 dev eth3 2>/dev/null && ip link set eth3 up
ip addr add 192.223.4.1/24 dev eth4 2>/dev/null && ip link set eth4 up

# 3. DNS Resolver WAN
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 4. Aktifkan IP Forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1

# 5. Konfigurasi NAT MASQUERADE untuk seluruh subnet internal
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "[+] Konfigurasi jichi selesai. Status Interface:"
ip -br a
