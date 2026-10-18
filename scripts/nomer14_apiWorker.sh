#!/bin/bash
apt-get update
apt-get install -y nginx php-fpm php-mysql

PHP_SERVICE=$(ls /etc/init.d/ | grep php | head -n 1)
service $PHP_SERVICE restart

# Hapus TOTAL seluruh file bawaan di /var/www/api/
rm -rf /var/www/api/*
mkdir -p /var/www/api

cat << 'EOF' > /var/www/api/index.php
<?php
$db_host = "192.223.4.8";
$db_user = "worker";
$db_pass = "Worker2026";
$db_name = "db_shibuya_k24";

$client_ip = isset($_SERVER['HTTP_X_REAL_IP']) ? $_SERVER['HTTP_X_REAL_IP'] :
            (isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR']);

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if (!$conn->connect_error) {
    $stmt = $conn->prepare("INSERT INTO request_logs (client_ip) VALUES (?)");
    $stmt->bind_param("s", $client_ip);
    $stmt->execute();
    $stmt->close();
    $conn->close();
}

header('Content-Type: application/json');
echo json_encode([
    "status" => "success",
    "worker" => gethostname(),
    "client_ip" => $client_ip
]) . "\n";
?>
EOF

PHP_SOCK=$(find /run/php/ -name "*.sock" | head -n 1)

cat << EOF > /etc/nginx/sites-available/jujutsu-api
server {
    listen 80;
    server_name jujutsu.k24.com;

    root /var/www/api;
    index index.php;

    allow 192.223.4.2;
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

ln -sf /etc/nginx/sites-available/jujutsu-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service nginx restart