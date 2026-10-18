#!/bin/bash
apt-get update
apt-get install -y mariadb-server

# Membuat file konfigurasi khusus untuk Slave (server-id = 2)
cat << 'EOF' > /etc/mysql/mariadb.conf.d/99-slave.cnf
[mysqld]
bind-address = 0.0.0.0
server-id = 2
EOF

# Restart layanan MariaDB agar server-id baru diterapkan
service mariadb restart

# Eksekusi ulang perintah pendaftaran Slave ke Master
mysql -u root <<EOF
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='192.223.4.8',
    MASTER_USER='replica_user',
    MASTER_PASSWORD='Jujutsu2026',
    MASTER_LOG_FILE='mysql-bin.000002',
    MASTER_LOG_POS=1645;
START SLAVE;
EOF