#!/bin/bash
# ==============================================================
# Soal 8: Packet Capture Analisis Protokol DHCP (DORA & giaddr)
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer8_config.sh
# 
# Poin Analisis:
# 1. Urutan Siklus DORA: DHCPDISCOVER -> DHCPOFFER -> DHCPREQUEST -> DHCPACK
# 2. Server Identifier (192.223.4.10)
# 3. Alamat yang Ditawarkan / Disewa (Your-IP / yiaddr)
# 4. Field Gateway IP (giaddr):
#    - Network 2 (Divisi A) -> 192.223.2.1 (eth2 jichi)
#    - Network 3 (Divisi B) -> 192.223.3.1 (eth3 jichi)
# 5. Lease Time & Options (DNS, domain-name K24.com)
# ==============================================================

PCAP_FILE="/root/nomer8_capture.pcap"
COUNT="${1:-4}"

# 1. Pastikan tcpdump terpasang
if ! command -v tcpdump >/dev/null 2>&1; then
    echo "[*] Menginstall tcpdump..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y tcpdump
fi

echo "=========================================================="
echo "[*] Menjalankan tcpdump pada eth0 (Filter: port 67 or 68)"
echo "[*] Target penangkapan: $COUNT paket DHCP..."
echo "[*] File capture disimpan di: $PCAP_FILE"
echo "=========================================================="
rm -f "$PCAP_FILE"

# Jalankan tcpdump untuk menangkap paket
tcpdump -i eth0 -n -v -c "$COUNT" -w "$PCAP_FILE" "port 67 or port 68"

echo ""
echo "=========================================================="
echo "[*] Hasil Analisis Paket DHCP dari File PCAP:"
echo "=========================================================="
tcpdump -nr "$PCAP_FILE" -v

echo ""
echo "[+] Analisis Packet Capture Soal 8 Selesai."
