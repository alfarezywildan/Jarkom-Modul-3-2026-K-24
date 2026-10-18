#!/bin/bash
# ==============================================================
# Soal 7: Sinkronisasi dan Audit DHCP Server pada tengen
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer7_config.sh
# ==============================================================

echo "=========================================================="
echo "[*] [1] Validasi Sintaks Konfigurasi DHCP Server"
echo "=========================================================="
dhcpd -t -cf /etc/dhcp/dhcpd.conf
if [ $? -eq 0 ]; then
    echo "[+] Sintaks dhcpd.conf VALID."
    service isc-dhcp-server restart
    sleep 2
    service isc-dhcp-server status
else
    echo "[-] Sintaks dhcpd.conf TIDAK VALID!"
    exit 1
fi

echo ""
echo "=========================================================="
echo "[*] [2] Isi Database Lease Aktif (/var/lib/dhcp/dhcpd.leases)"
echo "=========================================================="
if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    cat /var/lib/dhcp/dhcpd.leases
else
    echo "[-] File /var/lib/dhcp/dhcpd.leases belum terbentuk."
fi

echo ""
echo "=========================================================="
echo "[*] [3] Rekapitulasi Alokasi Lease Aktif (Binding State Active)"
echo "=========================================================="
grep -E "(lease |hardware ethernet|binding state)" /var/lib/dhcp/dhcpd.leases 2>/dev/null
