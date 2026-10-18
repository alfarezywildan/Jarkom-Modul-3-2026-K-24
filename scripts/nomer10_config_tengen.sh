#!/bin/bash
# ==============================================================
# Soal 10: Autostart DHCP Server Lengkap Pasca Restart pada tengen
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer10_config.sh
# ==============================================================

echo "=========================================================="
echo "[*] Inisialisasi Konfigurasi Jaringan & DHCP Server pada tengen"
echo "=========================================================="

# 1. Pastikan IP statis dan default gateway
ip addr add 192.223.4.10/24 dev eth0 2>/dev/null
ip link set eth0 up
ip route replace default via 192.223.4.1 2>/dev/null
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 2. Pastikan paket isc-dhcp-server terinstall
if ! command -v dhcpd >/dev/null 2>&1; then
    echo "[*] Menginstall isc-dhcp-server dari cache atau repositori..."
    dpkg -i /root/cache/*.deb 2>/dev/null || (apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server)
fi

# 3. Konfigurasi INTERFACESv4
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server 2>/dev/null
grep -q '^INTERFACESv4=' /etc/default/isc-dhcp-server 2>/dev/null || echo 'INTERFACESv4="eth0"' >> /etc/default/isc-dhcp-server

# 4. Tulis /etc/dhcp/dhcpd.conf lengkap
mkdir -p /etc/dhcp
cat << 'EOC' > /etc/dhcp/dhcpd.conf
default-lease-time 7200;
max-lease-time 14400;
ddns-update-style none;
authoritative;

# Klasifikasi Client Network 2 (Divisi A)
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

# Klasifikasi Client Network 3 (Divisi B)
class "short-lease-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "short-lease-team" 1:02:42:6e:c3:10:00;       # ino
subclass "short-lease-team" 1:02:42:cf:96:66:00;   # kusakabe

class "long-lease-team" {
    match pick-first-value (option dhcp-client-identifier, hardware);
}
subclass "long-lease-team" 1:02:42:38:9a:92:00;       # miwa

# Subnet Lokal Network 4 (Data Center)
subnet 192.223.4.0 netmask 255.255.255.0 {
}

# Subnet Network 2 (Divisi A)
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

# Subnet Network 3 (Divisi B)
subnet 192.223.3.0 netmask 255.255.255.0 {
    option routers 192.223.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.3.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
    option domain-name "K24.com";
    option domain-search "K24.com";

    pool {
        allow members of "short-lease-team";
        deny members of "long-lease-team";
        range 192.223.3.10 192.223.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    pool {
        allow members of "long-lease-team";
        deny members of "short-lease-team";
        range 192.223.3.100 192.223.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }

    host kugisaki {
        hardware ethernet 02:42:0b:96:7a:00;
        fixed-address 192.223.3.99;
    }
}
EOC

# 5. Jalankan service jika belum aktif
if ! pgrep -f "dhcpd" >/dev/null 2>&1; then
    echo "[*] Menjalankan service isc-dhcp-server..."
    service isc-dhcp-server restart >/dev/null 2>&1
    sleep 2
fi

echo "[+] Status Layanan dhcpd:"
ps aux | grep dhcpd | grep -v grep
