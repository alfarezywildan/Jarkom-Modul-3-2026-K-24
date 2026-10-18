#!/bin/bash
apt-get update
apt-get install -y nginx

# Membuat direktori penyimpanan cache Nginx
mkdir -p /var/cache/nginx/jujutsu

cat << 'EOF' > /etc/nginx/sites-available/jujutsu-public
# Definisi Proxy Cache: zone web_cache dengan masa aktif 10m
proxy_cache_path /var/cache/nginx/jujutsu levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=10m use_temp_path=off;

# Definisi Rate Limiting: 10 request per detik per IP klien
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

upstream web_frontend {
    server 192.223.4.3:80; # maki
    server 192.223.4.4:80; # panda
}

upstream api_gateway {
    server 192.223.4.2:80; # geto
}

server {
    listen 80;
    server_name jujutsu.k24.com www.jujutsu.k24.com;

    # Menambahkan header X-Cache-Status untuk pemantauan cache
    add_header X-Cache-Status $upstream_cache_status;

    # 1. Routing Frontend (Root /) dengan Proxy Caching
    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Konfigurasi Cache 10 Menit
        proxy_cache web_cache;
        proxy_cache_valid 200 10m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
    }

    # 2. Routing API (/api) dengan Rate Limiting 10r/s
    location /api {
        # Menerapkan aturan Rate Limit
        limit_req zone=api_limit nodelay;

        proxy_pass http://api_gateway/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Aktifkan konfigurasi
ln -sf /etc/nginx/sites-available/jujutsu-public /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Restart Nginx
service nginx restart