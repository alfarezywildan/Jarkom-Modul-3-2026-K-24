#!/bin/bash
# ==============================================================
# Soal 2: Konfigurasi Dasar ISC-DHCP-Server pada tengen
# Node Target: tengen (192.223.4.10)
# Lokasi     : /root/nomer2_config.sh
# ==============================================================

# 1. Pastikan paket isc-dhcp-server terpasang
if ! command -v dhcpd >/dev/null 2>&1; then
    echo "[*] Menginstall isc-dhcp-server..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server
fi

# 2. Atur INTERFACESv4 pada /etc/default/isc-dhcp-server
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server 2>/dev/null
grep -q '^INTERFACESv4=' /etc/default/isc-dhcp-server 2>/dev/null || echo 'INTERFACESv4="eth0"' >> /etc/default/isc-dhcp-server

# 3. Tulis konfigurasi /etc/dhcp/dhcpd.conf
cat << 'EOC' > /etc/dhcp/dhcpd.conf
default-lease-time 7200;
max-lease-time 14400;
ddns-update-style none;
authoritative;

# Deklarasi Subnet Lokal Network 4 (Data Center) tanpa pool dinamis
# Wajib ada agar tidak memunculkan error "No subnet declaration"
subnet 192.223.4.0 netmask 255.255.255.0 {
}

# Scope Subnet Network 2 (Divisi A)
subnet 192.223.2.0 netmask 255.255.255.0 {
    option routers 192.223.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.2.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
}

# Scope Subnet Network 3 (Divisi B)
subnet 192.223.3.0 netmask 255.255.255.0 {
    option routers 192.223.3.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.223.3.255;
    option domain-name-servers 192.223.1.2, 192.223.1.3;
}
EOC

# 4. Validasi sintaks dhcpd.conf
echo "[*] Memvalidasi sintaks konfigurasi dhcpd..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf
if [ $? -eq 0 ]; then
    echo "[+] Validasi sintaks dhcpd.conf SUKSES (Error code: 0)."
    service isc-dhcp-server restart
    sleep 2
    service isc-dhcp-server status
else
    echo "[-] Validasi sintaks dhcpd.conf GAGAL!"
fi

echo "[+] Konfigurasi Soal 2 pada tengen selesai."
