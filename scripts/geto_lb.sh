#!/bin/bash
apt-get update
apt-get install -y nginx

# Konfigurasi Load Balancer Nginx
cat << 'EOF' > /etc/nginx/sites-available/api-lb
upstream api_cluster {
    server 192.223.4.5:80 weight=3; # nanami
    server 192.223.4.6:80 weight=1; # todo
}

server {
    listen 80;
    server_name jujutsu.k24.com;

    location / {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Mengaktifkan konfigurasi dan menghapus default site
ln -sf /etc/nginx/sites-available/api-lb /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Restart layanan Nginx
service nginx restart