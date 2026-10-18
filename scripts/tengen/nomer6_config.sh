#!/bin/bash
# ==============================================================
# Soal 6: Konfigurasi DHCP Static Lease (VIP Kugisaki) pada tengen
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer6_config.sh
# 
# Parameter VIP:
# - Nama Host   : kugisaki
# - MAC Address : 02:42:0b:96:7a:00
# - Fixed IP    : 192.223.3.99 (di luar pool 3.10-3.89 dan 3.100-3.199)
# ==============================================================

cat << 'EOC' > /etc/dhcp/dhcpd.conf
default-lease-time 7200;
max-lease-time 14400;
ddns-update-style none;
authoritative;

# -------------------------------------------------------------
# Kelas DHCP Network 2 (Divisi A)
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
# Kelas DHCP Network 3 (Divisi B)
# -------------------------------------------------------------
class "short-lease-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "short-lease-team" 1:02:42:6e:c3:10:00;       # ino
subclass "short-lease-team" 1:02:42:cf:96:66:00;   # kusakabe

class "long-lease-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "long-lease-team" 1:02:42:38:9a:92:00;       # miwa

# -------------------------------------------------------------
# Subnet Lokal Network 4 (Data Center)
# -------------------------------------------------------------
subnet 192.223.4.0 netmask 255.255.255.0 {
}

# -------------------------------------------------------------
# Scope DHCP Network 2 (Divisi A)
# -------------------------------------------------------------
subnet 192.223.2.0 netmask 255.255.255.0 {
    option routers 192.223.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.2.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
    option domain-name "K24.com";
    option domain-search "K24.com";

    pool {
        allow members of "dev-team";
        deny members of "support-team";
        range 192.223.2.10 192.223.2.35;
    }

    pool {
        allow members of "support-team";
        deny members of "dev-team";
        range 192.223.2.70 192.223.2.95;
    }
}

# -------------------------------------------------------------
# Scope DHCP Network 3 (Divisi B) dengan Static Lease VIP
# -------------------------------------------------------------
subnet 192.223.3.0 netmask 255.255.255.0 {
    option routers 192.223.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.3.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
    option domain-name "K24.com";
    option domain-search "K24.com";

    # Pool Short Lease (30 menit)
    pool {
        allow members of "short-lease-team";
        deny members of "long-lease-team";
        range 192.223.3.10 192.223.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Pool Long Lease (12 jam)
    pool {
        allow members of "long-lease-team";
        deny members of "short-lease-team";
        range 192.223.3.100 192.223.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }

    # Static Lease Personel VIP (kugisaki) di luar seluruh pool dinamis
    host kugisaki {
        hardware ethernet 02:42:0b:96:7a:00;
        fixed-address 192.223.3.99;
    }
}
EOC

echo "[*] Memvalidasi sintaks /etc/dhcp/dhcpd.conf..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf
if [ $? -eq 0 ]; then
    echo "[+] Validasi sintaks dhcpd.conf BERHASIL."
    service isc-dhcp-server restart
    sleep 2
    service isc-dhcp-server status
else
    echo "[-] Validasi sintaks dhcpd.conf GAGAL!"
fi

echo "[*] Verifikasi blok host kugisaki:"
grep -A 4 "host kugisaki" /etc/dhcp/dhcpd.conf

echo "[+] Konfigurasi Soal 6 pada tengen selesai."
