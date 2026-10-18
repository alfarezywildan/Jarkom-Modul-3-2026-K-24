#!/bin/bash
apt-get update
apt-get install -y nginx php-fpm

# Pastikan service PHP-FPM aktif
PHP_SERVICE=$(ls /etc/init.d/ | grep php | head -n 1)
service $PHP_SERVICE restart

# Hapus TOTAL seluruh file bawaan di /var/www/html/
rm -rf /var/www/html/*

# Buat file index.php baru
cat << 'EOF' > /var/www/html/index.php
<?php
echo "Frontend Worker: " . gethostname() . "\n";
?>
EOF

# Deteksi otomatis socket PHP-FPM
PHP_SOCK=$(find /run/php/ -name "*.sock" | head -n 1)

# Buat konfigurasi Nginx baru (hanya mengarahkan ke index.php)
cat << EOF > /etc/nginx/sites-available/jujutsu-frontend
server {
    listen 80;
    server_name jujutsu.k24.com www.jujutsu.k24.com;

    root /var/www/html;
    index index.php;

    allow 192.223.1.4;
    deny all;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCK;
    }
}
EOF

ln -sf /etc/nginx/sites-available/jujutsu-frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service nginx restart