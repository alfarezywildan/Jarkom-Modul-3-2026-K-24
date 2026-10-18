#!/bin/bash

cat << 'EOF' > /etc/nginx/sites-available/api-lb
upstream api_cluster {
    server 192.223.4.5:80 weight=3; # nanami
    server 192.223.4.6:80 weight=1; # todo
}

server {
    listen 80;
    server_name jujutsu.k24.com;

    # Mempercayai header IP dari public reverse proxy (gojo)
    set_real_ip_from 192.223.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        # $remote_addr sekarang berisi IP asli klien berkat real_ip_header
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Restart Nginx untuk menerapkan pengaturan baru
service nginx restart