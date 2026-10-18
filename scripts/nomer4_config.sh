#!/bin/bash
# ==============================================================
# Soal 4: Konfigurasi DHCP Class & Dua Pool pada Network 2
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer4_config.sh
# 
# Pembagian Alokasi Network 2 (Divisi A):
# - Pool 1 (Dev): 192.223.2.10 - 192.223.2.35 (itadori, fushiguro)
# - Pool 2 (Support): 192.223.2.70 - 192.223.2.95 (zenin, okkotsu)
# - Rentang 192.223.2.36 - 192.223.2.69 TIDAK BOLEH dialokasikan
# ==============================================================

cat << 'EOC' > /etc/dhcp/dhcpd.conf
default-lease-time 7200;
max-lease-time 14400;
ddns-update-style none;
authoritative;

# -------------------------------------------------------------
# Definisi DHCP Class berdasarkan MAC Address Client
# -------------------------------------------------------------
class "dev-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "dev-team" 1:02:42:0f:8a:0e:00;    # itadori
subclass "dev-team" 1:02:42:b4:99:13:00;  # fushiguro

class "support-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "support-team" 1:02:42:dc:1b:f9:00;    # zenin
subclass "support-team" 1:02:42:a9:2a:e0:00;  # okkotsu

# -------------------------------------------------------------
# Subnet Lokal Network 4 (Data Center) - Tanpa Pool Dinamis
# -------------------------------------------------------------
subnet 192.223.4.0 netmask 255.255.255.0 {
}

# -------------------------------------------------------------
# Scope DHCP Network 2 (Divisi A) dengan 2 Pool Terpisah
# -------------------------------------------------------------
subnet 192.223.2.0 netmask 255.255.255.0 {
    option routers 192.223.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.2.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;

    # Pool 1: Khusus Dev Team (itadori, fushiguro)
    pool {
        allow members of "dev-team";
        deny members of "support-team";
        range 192.223.2.10 192.223.2.35;
    }

    # Pool 2: Khusus Support Team (zenin, okkotsu)
    pool {
        allow members of "support-team";
        deny members of "dev-team";
        range 192.223.2.70 192.223.2.95;
    }
}

# -------------------------------------------------------------
# Scope DHCP Network 3 (Divisi B)
# -------------------------------------------------------------
subnet 192.223.3.0 netmask 255.255.255.0 {
    range 192.223.3.10 192.223.3.89;
    option routers 192.223.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.3.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
}
EOC

echo "[*] Memvalidasi sintaks /etc/dhcp/dhcpd.conf..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf
if [ $? -eq 0 ]; then
    echo "[+] Validasi sintaks dhcpd.conf BERHASIL (Error code: 0)."
    service isc-dhcp-server restart
    sleep 2
    service isc-dhcp-server status
else
    echo "[-] Validasi sintaks dhcpd.conf GAGAL!"
fi

echo "[+] Konfigurasi Soal 4 pada tengen selesai."
