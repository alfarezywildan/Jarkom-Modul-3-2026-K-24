# 1. Konfigurasi DNS Forwarder
cat << 'EOF' > /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        forwarders {
                192.168.122.1;
        };
        forward only;
        dnssec-validation auto;
        listen-on-v6 { any; };
};
EOF

# 2. Tambahkan A record dan CNAME pada file zone utama yang sudah dibuat di No 11
echo "jujutsu.k24.com. IN A 192.223.1.4" >> /etc/bind/jujutsu/jujutsu.k24.com
echo "www IN CNAME jujutsu.k24.com." >> /etc/bind/jujutsu/jujutsu.k24.com

# 3. Daftarkan Reverse Zone pada named.conf.local
cat << 'EOF' >> /etc/bind/named.conf.local

zone "1.223.192.in-addr.arpa" {
    type master;
    file "/etc/bind/jujutsu/1.223.192.rev";
    allow-transfer { 192.223.1.3; };
};
EOF

# 4. Buat file Reverse Zone untuk IP gojo
cat << 'EOF' > /etc/bind/jujutsu/1.223.192.rev
$TTL    604800
@       IN      SOA     utahime.jujutsu.k24.com. admin.jujutsu.k24.com. (
                              2026101503 ; Serial
                                  604800 ; Refresh
                                   86400 ; Retry
                                 2419200 ; Expire
                                  604800 ) ; Negative Cache TTL
;
@       IN      NS      utahime.jujutsu.k24.com.
@       IN      NS      shoko.jujutsu.k24.com.

4       IN      PTR     jujutsu.k24.com.
EOF

# 5. Restart layanan BIND9
service named restart