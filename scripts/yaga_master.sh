#!/bin/bash
apt-get update
apt-get install -y mariadb-server

# Membuat file konfigurasi khusus untuk pengaturan Master
cat << 'EOF' > /etc/mysql/mariadb.conf.d/99-master.cnf
[mysqld]
bind-address = 0.0.0.0
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
EOF

# Memastikan direktori log tersedia dengan kepemilikan user mysql
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Restart layanan MariaDB agar konfigurasi baru diterapkan
service mariadb restart

# Eksekusi query untuk membuat DB, tabel, dan hak akses
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS db_shibuya_k24;
USE db_shibuya_k24;

-- Membuat tabel request_logs
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(50) NOT NULL,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Membuat user untuk replikasi Slave
CREATE USER IF NOT EXISTS 'replica_user'@'%' IDENTIFIED BY 'Jujutsu2026';
GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';

-- Memberikan hak akses remote bagi seluruh node di Network 4
CREATE USER IF NOT EXISTS 'worker'@'192.223.4.%' IDENTIFIED BY 'Worker2026';
GRANT ALL PRIVILEGES ON db_shibuya_k24.* TO 'worker'@'192.223.4.%';

FLUSH PRIVILEGES;
EOF