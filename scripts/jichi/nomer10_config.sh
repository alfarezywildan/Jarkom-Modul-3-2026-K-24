#!/bin/bash
# ==============================================================
# Soal 10: Autostart DHCP Relay & Jaringan Pasca Restart pada jichi
# Node Target: jichi
# Lokasi     : /root/nomer10_config.sh
# 
# Fungsi:
# 1. Menetapkan alamat IP statis interface WAN & LAN (eth0 - eth4)
# 2. Mengaktifkan IPv4 forwarding & NAT iptables MASQUERADE
# 3. Memulihkan dependensi paket isc-dhcp-relay dari cache lokal
# 4. Menjalankan daemon dhcrelay secara persisten saat booting
# ==============================================================

echo "=========================================================="
echo "[*] Inisialisasi Konfigurasi Jaringan & DHCP Relay pada jichi"
echo "=========================================================="

# 1. Pastikan IP Address dan Gateway WAN
ip addr add 192.168.122.20/24 dev eth0 2>/dev/null
ip link set eth0 up
ip route replace default via 192.168.122.1 2>/dev/null

# 2. Pastikan IP Interface Internal Network 1 - 4
ip addr add 192.223.1.1/24 dev eth1 2>/dev/null && ip link set eth1 up
ip addr add 192.223.2.1/24 dev eth2 2>/dev/null && ip link set eth2 up
ip addr add 192.223.3.1/24 dev eth3 2>/dev/null && ip link set eth3 up
ip addr add 192.223.4.1/24 dev eth4 2>/dev/null && ip link set eth4 up

# 3. Aktifkan IPv4 Forwarding & NAT iptables
sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 4. Pastikan paket isc-dhcp-relay terpasang (Gunakan offline cache jika offline)
if ! command -v dhcrelay >/dev/null 2>&1; then
    echo "[*] Menginstall isc-dhcp-relay dari cache atau repositori..."
    dpkg -i /root/cache/*.deb 2>/dev/null || (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay)
fi

# 5. Jalankan DHCP Relay jika belum aktif
if ! pgrep -f "dhcrelay" >/dev/null 2>&1; then
    echo "[*] Menjalankan daemon dhcrelay..."
    /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10
    sleep 1
fi

echo "[+] Status Interface jichi:"
ip -br a
echo "[+] Status Layanan dhcrelay:"
ps aux | grep dhcrelay | grep -v grep
