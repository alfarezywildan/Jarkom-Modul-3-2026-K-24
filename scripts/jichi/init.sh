#!/bin/sh
# ==============================================================
# Soal 10: Boot Hook Script (/root/init.sh) pada jichi
# Node Target: jichi
# Lokasi     : /root/init.sh
# 
# Penjelasan:
# File ini dipanggil secara otomatis oleh /etc/debinet-init.sh
# dan /root/.bashrc setiap kali container booting atau di-reload,
# sehingga mengeksekusi /root/nomer10_config.sh secara otomatis.
# ==============================================================

if [ -x /root/nomer10_config.sh ]; then
    /root/nomer10_config.sh
fi
