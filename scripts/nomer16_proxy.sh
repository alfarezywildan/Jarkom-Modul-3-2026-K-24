#!/bin/bash
apt-get update
apt-get install -y nginx

# Upstream untuk Worker Frontend (Round Robin)
cat << 'EOF' > /etc/nginx/sites-available/jujutsu-public
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

    # Routing ke Frontend (Root /)
    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Routing ke API (/api)
    location /api {
        proxy_pass http://api_gateway/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Mengaktifkan site dan menghapus default site
ln -sf /etc/nginx/sites-available/jujutsu-public /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Restart Nginx
service nginx restart