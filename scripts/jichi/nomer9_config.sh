#!/bin/bash
# ==============================================================
# Soal 9: Simulasi Gangguan & Pemulihan DHCP Relay pada jichi
# Node Target: jichi
# Lokasi     : /root/nomer9_config.sh
# 
# Penggunaan:
# - /root/nomer9_config.sh stop    : Hentikan relay (Simulasi Outage)
# - /root/nomer9_config.sh start   : Pulihkan relay (Simulasi Recovery)
# - /root/nomer9_config.sh status  : Cek status proses relay
# ==============================================================

ACTION="${1:-status}"

case "$ACTION" in
    stop)
        echo "=========================================================="
        echo "[*] Menghentikan service DHCP Relay (dhcrelay)..."
        echo "=========================================================="
        pkill -9 dhcrelay 2>/dev/null
        sleep 1
        echo "[+] Status setelah dihentikan:"
        ps aux | grep dhcrelay | grep -v grep || echo "[-] dhcrelay TIDAK AKTIF (Berhasil Dihentikan)"
        ;;
    start|restore)
        echo "=========================================================="
        echo "[*] Memulihkan / Menjalankan service DHCP Relay..."
        echo "=========================================================="
        pkill -9 dhcrelay 2>/dev/null
        sleep 1
        /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10
        sleep 1
        echo "[+] Status setelah dipulihkan:"
        ps aux | grep dhcrelay | grep -v grep
        if pgrep -f "dhcrelay" >/dev/null 2>&1; then
            echo "[+] dhcrelay BERHASIL dipulihkan dan aktif melayani eth2, eth3, eth4."
        else
            echo "[-] Gagal memulihkan dhcrelay!"
        fi
        ;;
    status)
        echo "=========================================================="
        echo "[*] Status Layanan DHCP Relay Saat Ini:"
        echo "=========================================================="
        ps aux | grep dhcrelay | grep -v grep || echo "[-] dhcrelay TIDAK AKTIF"
        ;;
    *)
        echo "Penggunaan: $0 {stop|start|restore|status}"
        exit 1
        ;;
esac
