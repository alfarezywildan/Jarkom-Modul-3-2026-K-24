#!/bin/bash

# Update dan instalasi BIND9 beserta dnsutils untuk pengujian
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils

# Membuat direktori untuk menyimpan file zone
mkdir -p /etc/bind/jujutsu

# Konfigurasi zona master dan allow-transfer pada named.conf.local
cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k24.com" {
    type master;
    file "/etc/bind/jujutsu/jujutsu.k24.com";
    allow-transfer { 192.223.1.3; };
};
EOF

# Membuat file zone dengan konfigurasi SOA dan NS delegasi
cat << 'EOF' > /etc/bind/jujutsu/jujutsu.k24.com
$TTL    604800
@       IN      SOA     utahime.jujutsu.k24.com. admin.jujutsu.k24.com. (
                              2026101501 ; Serial
                                  604800 ; Refresh
                                   86400 ; Retry
                                 2419200 ; Expire
                                  604800 ) ; Negative Cache TTL
;
; Name Server Delegations
@       IN      NS      utahime.jujutsu.k24.com.
@       IN      NS      shoko.jujutsu.k24.com.

; A Records untuk Name Servers
utahime IN      A       192.223.1.2
shoko   IN      A       192.223.1.3
EOF

# Restart layanan BIND9
service named restart

echo "utahime jadi dns master"