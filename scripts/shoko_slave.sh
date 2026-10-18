#!/bin/bash

# Update dan instalasi BIND9 beserta dnsutils
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils

# Konfigurasi zona slave pada named.conf.local
cat << 'EOF' > /etc/bind/named.conf.local
zone "jujutsu.k24.com" {
    type slave;
    file "/var/lib/bind/jujutsu.k24.com";
    masters { 192.223.1.2; };
};
EOF

# Restart layanan BIND9
service named restart
echo "shoko jadi dns slave"