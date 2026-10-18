#!/bin/bash
# ==============================================================
# Soal 3: Konfigurasi DHCP Relay pada Router jichi
# Node Target: jichi
# Lokasi     : /root/nomer3_config.sh
# ==============================================================

echo "[*] Menyiapkan DHCP Relay pada Router jichi..."

# 1. Pastikan paket isc-dhcp-relay terpasang
if ! command -v dhcrelay >/dev/null 2>&1; then
    echo "[*] Menginstall isc-dhcp-relay..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay
fi

# 2. Hentikan proses dhcrelay lama jika ada
killall dhcrelay 2>/dev/null
sleep 1

# 3. Jalankan daemon dhcrelay
# Interface client: eth2 (Network 2 - Divisi A), eth3 (Network 3 - Divisi B)
# Interface server: eth4 (Network 4 - Data Center)
# IP Target DHCP Server: 192.223.4.10 (tengen)
echo "[*] Menjalankan daemon dhcrelay melayani eth2, eth3, eth4 -> 192.223.4.10..."
/usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10
sleep 1

# 4. Tampilkan status proses
echo "[*] Memeriksa status proses dhcrelay:"
ps aux | grep dhcrelay | grep -v grep

if pgrep -f "dhcrelay" >/dev/null 2>&1; then
    echo "[+] Layanan DHCP Relay BERHASIL berjalan aktif di router jichi."
else
    echo "[-] Gagal menjalankan DHCP Relay pada router jichi!"
fi
