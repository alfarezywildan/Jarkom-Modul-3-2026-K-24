# Jarkom-Modul-3-2026-K-24

## Anggota Kelompok

| Nama | NRP |
| ------------------------- | ---------- |
| Wildan Alfarezy | 5027251088 |
| Ashkhabil Abror Budihardjo | 5027251049 |

## Laporan

# Laporan Praktikum Modul 3 - Jaringan Komputer (K-24)

### Topologi Jaringan
![Topologi Jaringan GNS3](assets/topologi_gns3.png)

### Informasi Parameter Praktikum
* Prefix IP Kelompok : `192.223.x.x`
* Domain Name : `K24.com`
* Gateway Internet (WAN) : `192.168.122.1`

---

### Soal 1

> Ketika Curtain menutup Shibuya, jalur komunikasi antar zona Jujutsu High terputus. Pulihkan konektivitas dasar dengan mengonfigurasi jichi: eth0 memperoleh WAN dari NAT, sedangkan eth1-eth4 menjadi gateway Network 1-4 sesuai tabel pemetaan. Aktifkan IPv4 forwarding dan source NAT, lalu tetapkan IP statis host infrastruktur sesuai tabel spesifikasi. Buktikan konektivitas setiap host ke gateway dan akses eksternal dari host yang relevan.

### Maksud dari Soal No. 1
Soal ini bertujuan untuk membangun fondasi konektivitas dasar seluruh topologi jaringan. Node **jichi** berperan sebagai router sentral yang menghubungkan empat jaringan internal (Network 1 sampai Network 4) ke jaringan luar (Internet/NAT). Konfigurasi ini mencakup penetapan alamat IP statis pada setiap interface router dan host infrastruktur (**tengen**), pengaktifan fitur penerusan paket IPv4 (*IP forwarding*), serta translasi alamat jaringan (*Source NAT/MASQUERADE*) pada router jichi agar seluruh node di jaringan lokal dapat mengakses internet.

### Cara Mengerjakan

1. **Konfigurasi Router (jichi)**:
   * Interface `eth0` dikonfigurasi untuk terhubung ke gateway internet (`192.168.122.1`).
   * Interface `eth1` sampai `eth4` dikonfigurasi sebagai gateway untuk masing-masing subnet:
     * `eth1`: `192.223.1.1/24` (Network 1 - DMZ)
     * `eth2`: `192.223.2.1/24` (Network 2 - Divisi A)
     * `eth3`: `192.223.3.1/24` (Network 3 - Divisi B)
     * `eth4`: `192.223.4.1/24` (Network 4 - Data Center)
   * Mengaktifkan IP forwarding pada kernel Linux dengan perintah `sysctl -w net.ipv4.ip_forward=1`.
   * Mengonfigurasi iptables untuk melakukan Source NAT (`MASQUERADE`) pada interface keluar `eth0`.
   * Seluruh konfigurasi ini disimpan dalam skrip `/root/nomer1_config.sh` pada node jichi.

   Isi skrip `/root/nomer1_config.sh` pada node **jichi**:
   ```bash
   #!/bin/bash
   # Konfigurasi Jaringan & NAT pada Router jichi

   # 1. Konfigurasi IP Interface
   ip addr add 192.168.122.20/24 dev eth0 2>/dev/null
   ip link set eth0 up
   ip route replace default via 192.168.122.1 2>/dev/null

   ip addr add 192.223.1.1/24 dev eth1 2>/dev/null
   ip link set eth1 up
   ip addr add 192.223.2.1/24 dev eth2 2>/dev/null
   ip link set eth2 up
   ip addr add 192.223.3.1/24 dev eth3 2>/dev/null
   ip link set eth3 up
   ip addr add 192.223.4.1/24 dev eth4 2>/dev/null
   ip link set eth4 up

   # 2. Aktifkan IPv4 Forwarding
   sysctl -w net.ipv4.ip_forward=1

   # 3. Konfigurasi Source NAT (MASQUERADE)
   iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

   # 4. Atur DNS resolver jichi
   echo "nameserver 192.168.122.1" > /etc/resolv.conf

   echo "[+] Konfigurasi jichi selesai."
   ```

2. **Konfigurasi Host Infrastruktur (tengen)**:
   * Menetapkan alamat IP statis pada interface `eth0` sebesar `192.223.4.10/24`.
   * Menetapkan default gateway yang mengarah ke IP router jichi pada Network 4 (`192.223.4.1`).
   * Menetapkan nameserver sementara ke `192.168.122.1` untuk instalasi paket.
   * Seluruh konfigurasi disimpan dalam skrip `/root/nomer1_config.sh` pada node tengen.

   Isi skrip `/root/nomer1_config.sh` pada node **tengen**:
   ```bash
   #!/bin/bash
   # Konfigurasi IP Statis & Gateway pada tengen

   ip addr add 192.223.4.10/24 dev eth0 2>/dev/null
   ip link set eth0 up
   ip route replace default via 192.223.4.1 2>/dev/null
   echo "nameserver 192.168.122.1" > /etc/resolv.conf

   echo "[+] Konfigurasi tengen selesai."
   ```

### Cara Melakukan Validasi

1. **Uji Interface dan Routing pada Router jichi**:
   * Jalankan perintah `ip -br a` pada console jichi untuk memastikan seluruh interface `eth0` sampai `eth4` aktif dan memiliki IP yang sesuai.
   * Jalankan perintah `sysctl net.ipv4.ip_forward` untuk memastikan nilainya bernilai `1`.
   * Jalankan `iptables -t nat -L -v -n` untuk memastikan aturan `MASQUERADE` terpasang.
   ![Status Interface dan NAT Router jichi](assets/soal1_jichi_interfaces.png)

2. **Uji Konektivitas Gateway dan Internet dari tengen**:
   * Dari console tengen, jalankan `ping -c 2 192.223.4.1` untuk membuktikan konektivitas ke gateway jichi.
   * Jalankan `ping -c 2 8.8.8.8` untuk membuktikan akses internet keluar melalui NAT jichi.
   ![Uji Ping Gateway dan Internet dari tengen](assets/soal1_tengen_ping.png)

---

### Soal 2

> Tengen, penjaga pusat distribusi di Data Center, harus mengambil alih pengalokasian alamat bagi wilayah yang membutuhkan konfigurasi dinamis. Konfigurasikan isc-dhcp-server pada [PREFIX IP].4.10. Deklarasikan Network 4 ([PREFIX IP].4.0/24) sebagai subnet lokal tanpa pool dinamis, lalu siapkan scope DHCP untuk Network 2 ([PREFIX IP].2.0/24) dan Network 3 ([PREFIX IP].3.0/24). Validasi konfigurasi dan pastikan service aktif tanpa error "No subnet declaration".

### Maksud dari Soal No. 2
Soal ini meminta pemasangan dan inisialisasi layanan DHCP Server menggunakan paket `isc-dhcp-server` pada server **tengen** (`192.223.4.10`). Pada arsitektur DHCP ISC, daemon `dhcpd` mewajibkan adanya deklarasi subnet lokal (subnet di mana interface server tersebut berada) pada file konfigurasinya. Jika subnet lokal tidak dideklarasikan, daemon akan menolak berjalan dengan memunculkan error *"No subnet declaration for eth0"*. Subnet lokal Network 4 (`192.223.4.0/24`) harus dideklarasikan secara eksplisit tanpa rentang pool dinamis (karena server dan node Data Center menggunakan alamat statis), serta menyiapkan blok subnet untuk Network 2 dan Network 3 yang nantinya akan menerima alokasi dinamis.

### Cara Mengerjakan

1. **Instalasi Paket**:
   Menginstal paket `isc-dhcp-server` pada node tengen melalui APT package manager.

2. **Pengaturan Interface**:
   Mengonfigurasi file `/etc/default/isc-dhcp-server` agar mendengarkan permintaan DHCP IPv4 secara spesifik pada interface `eth0`:
   ```bash
   INTERFACESv4="eth0"
   ```

3. **Deklarasi Subnet pada `/etc/dhcp/dhcpd.conf`**:
   * Menuliskan subnet lokal Network 4 (`192.223.4.0 netmask 255.255.255.0`) tanpa deklarasi rentang (*range*).
   * Menuliskan scope subnet Network 2 (`192.223.2.0/24`) dan Network 3 (`192.223.3.0/24`) beserta opsi gateway router masing-masing.

4. **Pembuatan Skrip Konfigurasi**:
   Seluruh langkah otomatisasi disimpan di `/root/nomer2_config.sh` pada node tengen.

   Isi skrip `/root/nomer2_config.sh` pada node **tengen**:
   ```bash
   #!/bin/bash
   # Konfigurasi Dasar ISC-DHCP-Server pada tengen

   # 1. Pastikan paket terpasang
   if ! command -v dhcpd >/dev/null 2>&1; then
       echo "[*] Menginstall isc-dhcp-server..."
       apt-get update
       DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-server
   fi

   # 2. Atur interface IPv4
   sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server 2>/dev/null
   grep -q '^INTERFACESv4=' /etc/default/isc-dhcp-server 2>/dev/null || echo 'INTERFACESv4="eth0"' >> /etc/default/isc-dhcp-server

   # 3. Tulis konfigurasi dhcpd.conf
   cat << 'EOC' > /etc/dhcp/dhcpd.conf
   default-lease-time 7200;
   max-lease-time 14400;
   ddns-update-style none;
   authoritative;

   # Deklarasi Subnet Lokal Network 4 (Tanpa Pool Dinamis)
   subnet 192.223.4.0 netmask 255.255.255.0 {
   }

   # Scope Subnet Network 2 (Divisi A)
   subnet 192.223.2.0 netmask 255.255.255.0 {
       option routers 192.223.2.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.223.2.255;
       option domain-name-servers 192.223.1.2, 192.223.1.3;
   }

   # Scope Subnet Network 3 (Divisi B)
   subnet 192.223.3.0 netmask 255.255.255.0 {
       option routers 192.223.3.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.223.3.255;
       option domain-name-servers 192.223.1.2, 192.223.1.3;
   }
   EOC

   # 4. Validasi sintaks dan restart layanan
   dhcpd -t -cf /etc/dhcp/dhcpd.conf
   service isc-dhcp-server restart
   service isc-dhcp-server status
   ```

### Cara Melakukan Validasi

1. **Pemeriksaan Status Layanan pada tengen**:
   * Jalankan `service isc-dhcp-server status` dan `ps aux | grep dhcpd` pada console tengen.
   * Layanan berjalan normal (`dhcpd is running`) pada interface `eth0` tanpa ada error *"No subnet declaration"*.
   ![Status Layanan isc-dhcp-server pada tengen](assets/soal2_dhcpd_status.png)

---

### Soal 3

> Permintaan alamat dari Divisi A dan Divisi B tidak dapat menyeberangi subnet secara langsung. Konfigurasikan jichi sebagai DHCP Relay menuju tengen ([PREFIX IP].4.10), menggunakan eth2 untuk Network 2 dan eth3 untuk Network 3. Buktikan bahwa client dari kedua subnet berhasil memperoleh lease melalui relay.

### Maksud dari Soal No. 3
Paket *DHCP Discover* dan *DHCP Request* dari client dikirimkan menggunakan alamat broadcast Layer 2 (`ff:ff:ff:ff:ff:ff`), sehingga secara default paket tersebut tidak dapat melewati router untuk mencapai DHCP server di subnet yang berbeda (Network 4). Untuk mengatasi hal ini, router **jichi** dikonfigurasikan sebagai **DHCP Relay Agent** (`isc-dhcp-relay` / `dhcrelay`). Agen relay ini akan menangkap paket broadcast DHCP pada interface client (`eth2` untuk Network 2 dan `eth3` untuk Network 3), menyisipkan alamat IP gateway interface pada field `giaddr`, lalu meneruskannya secara unicast Layer 3 menuju server tengen (`192.223.4.10`). Jawaban dari server kemudian dikirimkan kembali ke relay untuk diteruskan ke client asal.

### Cara Mengerjakan

1. **Instalasi Paket DHCP Relay**:
   Menginstal paket `isc-dhcp-relay` pada node router jichi.

2. **Eksekusi Layanan Relay**:
   Menjalankan daemon `dhcrelay` dengan parameter interface yang menangani request dari client (`eth2`, `eth3`), interface pengirim/penerima ke arah server (`eth4`), serta alamat IP tujuan server DHCP (`192.223.4.10`):
   ```bash
   /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10
   ```

3. **Pembuatan Skrip Konfigurasi**:
   Seluruh langkah otomatisasi disimpan di `/root/nomer3_config.sh` pada node jichi.

   Isi skrip `/root/nomer3_config.sh` pada node **jichi**:
   ```bash
   #!/bin/bash
   # Konfigurasi DHCP Relay pada Router jichi

   # 1. Pastikan paket isc-dhcp-relay terinstall
   if ! command -v dhcrelay >/dev/null 2>&1; then
       apt-get update
       DEBIAN_FRONTEND=noninteractive apt-get install -y isc-dhcp-relay
   fi

   # 2. Hentikan proses lama jika ada
   killall dhcrelay 2>/dev/null

   # 3. Jalankan daemon dhcrelay
   /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10

   # 4. Tampilkan status proses
   ps aux | grep dhcrelay
   echo "[+] Konfigurasi DHCP Relay pada jichi selesai."
   ```

### Cara Melakukan Validasi

1. **Pemeriksaan Proses Relay di jichi**:
   * Jalankan `ps aux | grep dhcrelay` pada router jichi untuk memastikan daemon aktif mendengarkan interface `eth2`, `eth3`, `eth4` dengan target server `192.223.4.10`.
   ![Proses DHCP Relay pada jichi](assets/soal3_dhcrelay_jichi.png)

2. **Pembuktian Penerimaan Lease pada Client Network 2 (itadori)**:
   * Pada node **itadori**, jalankan `udhcpc -i eth0 -n -q && ip -br a show dev eth0 && ip route show && ping -c 2 8.8.8.8`.
   * Klien berhasil memperoleh lease IP `192.223.2.10` dari server `192.223.4.10`, gateway `192.223.2.1`, dan ping internet berhasil.
   ![Lease itadori Network 2 Melalui DHCP Relay](assets/soal3_itadori_relay_lease.png)

3. **Pembuktian Penerimaan Lease pada Client Network 3 (ino)**:
   * Pada node **ino**, jalankan `udhcpc -i eth0 -n -q && ip -br a show dev eth0 && ip route show && ping -c 2 8.8.8.8`.
   * Klien berhasil memperoleh lease IP `192.223.3.10` dari server `192.223.4.10`, gateway `192.223.3.1`, dan ping internet berhasil.
   ![Lease ino Network 3 Melalui DHCP Relay](assets/soal3_ino_relay_lease.png)

---

### Soal 4

> Agar tim Dev dan Support di Divisi A menerima jatah alamat yang berbeda, atur dua pool DHCP pada Network 2. Tetapkan Pool 1 ([PREFIX IP].2.10-[PREFIX IP].2.35) untuk itadori dan fushiguro, serta Pool 2 ([PREFIX IP].2.70-[PREFIX IP].2.95) untuk zenin dan okkotsu. Rentang [PREFIX IP].2.36-[PREFIX IP].2.69 tidak boleh dialokasikan. Karena seluruh client berada pada subnet yang sama, gunakan DHCP class berdasarkan MAC Address atau Client ID untuk memisahkan kedua kelompok.

### Maksud dari Soal No. 4
Soal ini menguji penerapan kebijakan pembagian IP berbasis kelompok (*classification*) dalam satu subnet fisik yang sama (Network 2). Tim Pengembang (*Dev Team*: **itadori** dan **fushiguro**) harus memperoleh IP dari **Pool 1** (`192.223.2.10` sampai `192.223.2.35`), sedangkan Tim Dukungan (*Support Team*: **zenin** dan **okkotsu**) harus memperoleh IP dari **Pool 2** (`192.223.2.70` sampai `192.223.2.95`). Rentang tengah (`192.223.2.36` sampai `192.223.2.69`) harus dikosongkan (*reserved*). Karena semua client berada pada switch yang sama, pemisahan dilakukan menggunakan fitur `class` dan `subclass` pada `dhcpd.conf` dengan mencocokkan MAC Address masing-masing node.

### Cara Mengerjakan

1. **Identifikasi MAC Address Client**:
   * itadori: `02:42:0f:8a:0e:00`
   * fushiguro: `02:42:b4:99:13:00`
   * zenin: `02:42:dc:1b:f9:00`
   * okkotsu: `02:42:a9:2a:e0:00`

2. **Mendefinisikan Class dan Subclass**:
   Pada `/etc/dhcp/dhcpd.conf` di node tengen, buat dua kelas:
   * Class `dev-team` dengan subclass berisi MAC itadori dan fushiguro.
   * Class `support-team` dengan subclass berisi MAC zenin dan okkotsu.

3. **Mendefinisikan Pool dengan Access Control**:
   * Pool 1: Diberi izin hanya untuk `allow members of "dev-team";` dan `deny members of "support-team";` dengan range `192.223.2.10 192.223.2.35`.
   * Pool 2: Diberi izin hanya untuk `allow members of "support-team";` dan `deny members of "dev-team";` dengan range `192.223.2.70 192.223.2.95`.

4. **Pembuatan Skrip Konfigurasi**:
   Seluruh langkah otomatisasi disimpan di `/root/nomer4_config.sh` pada node tengen.

   Cuplikan konfigurasi subnet Network 2 pada `/etc/dhcp/dhcpd.conf` (skrip `/root/nomer4_config.sh`):
   ```text
   class "dev-team" {
       match pick-first-value (option dhcp-client-identifier, hardware);
   }
   subclass "dev-team" 1:02:42:0f:8a:0e:00;    # itadori
   subclass "dev-team" 1:02:42:b4:99:13:00;  # fushiguro

   class "support-team" {
       match pick-first-value (option dhcp-client-identifier, hardware);
   }
   subclass "support-team" 1:02:42:dc:1b:f9:00;    # zenin
   subclass "support-team" 1:02:42:a9:2a:e0:00;  # okkotsu

   subnet 192.223.2.0 netmask 255.255.255.0 {
       option routers 192.223.2.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.223.2.255;
       option domain-name-servers 192.223.1.2, 192.223.1.3;

       pool {
           allow members of "dev-team";
           deny members of "support-team";
           range 192.223.2.10 192.223.2.35;
       }

       pool {
           allow members of "support-team";
           deny members of "dev-team";
           range 192.223.2.70 192.223.2.95;
       }
   }
   ```

### Cara Melakukan Validasi

1. **Uji Alokasi Tim Dev (Pool 1)**:
   * Pada node **itadori**, jalankan `/root/nomer4_client_test.sh`. Hasil: IP `192.223.2.10` (Sesuai Pool 1).
   ![Validasi Pool 1 pada itadori](assets/soal4_itadori_pool1.png)
   * Pada node **fushiguro**, jalankan `/root/nomer4_client_test.sh`. Hasil: IP `192.223.2.11` (Sesuai Pool 1).
   ![Validasi Pool 1 pada fushiguro](assets/soal4_fushiguro_pool1.png)

2. **Uji Alokasi Tim Support (Pool 2)**:
   * Pada node **zenin**, jalankan `/root/nomer4_client_test.sh`. Hasil: IP `192.223.2.70` (Sesuai Pool 2).
   ![Validasi Pool 2 pada zenin](assets/soal4_zenin_pool2.png)
   * Pada node **okkotsu**, jalankan `/root/nomer4_client_test.sh`. Hasil: IP `192.223.2.71` (Sesuai Pool 2).
   ![Validasi Pool 2 pada okkotsu](assets/soal4_okkotsu_pool2.png)

3. **Verifikasi Database Lease**:
   * File `/var/lib/dhcp/dhcpd.leases` pada tengen membuktikan pencatatan sewa untuk `192.223.2.10` dengan status `binding state active`.
   ![Database Lease dhcpd.leases pada tengen](assets/soal4_dhcpd_leases.png)

---

### Soal 5

> Setiap tim lapangan memiliki durasi operasi yang berbeda. Pada Network 3, berikan short lease 30 menit (1800 detik) kepada ino dan kusakabe, serta long lease 12 jam (43200 detik) kepada miwa. Gunakan pool short lease [PREFIX IP].3.10-[PREFIX IP].3.89 dan pool long lease [PREFIX IP].3.100-[PREFIX IP].3.199. Sesuaikan default-lease-time dan max-lease-time untuk setiap kelas client. Berikan pula DHCP options berupa DNS [PREFIX IP].1.2 dan [PREFIX IP].1.3, serta domain-search <xxxx>.com.

### Maksud dari Soal No. 5
Soal ini bertujuan menerapkan manajemen durasi sewa (*lease time*) dan pemberian opsi DHCP tingkat lanjut pada Network 3 (Divisi B). Klien lapangan dengan mobilitas tinggi (**ino** dan **kusakabe**) diberikan *short lease* berdurasi 30 menit (1800 detik) dalam rentang `192.223.3.10` – `192.223.3.89`. Klien stasioner (**miwa**) diberikan *long lease* berdurasi 12 jam (43200 detik) dalam rentang `192.223.3.100` – `192.223.3.199`. Selain itu, server harus mendistribusikan parameter DNS resolver primer (`192.223.1.2`), DNS resolver sekunder (`192.223.1.3`), serta domain pencarian `K24.com` melalui opsi DHCP.

### Cara Mengerjakan

1. **Identifikasi MAC Address Client Divisi B**:
   * ino: `02:42:6e:c3:10:00`
   * kusakabe: `02:42:cf:96:66:00`
   * miwa: `02:42:38:9a:92:00`

2. **Mendefinisikan Class di `dhcpd.conf`**:
   * Class `short-lease-team`: berisi MAC address ino dan kusakabe.
   * Class `long-lease-team`: berisi MAC address miwa.

3. **Mendefinisikan Pool dan Durasi Lease**:
   * Pool Short Lease: Dikonfigurasi dengan `default-lease-time 1800; max-lease-time 1800;` dan rentang `192.223.3.10 192.223.3.89`.
   * Pool Long Lease: Dikonfigurasi dengan `default-lease-time 43200; max-lease-time 43200;` dan rentang `192.223.3.100 192.223.3.199`.
   * Menambahkan parameter global subnet:
     ```text
     option domain-name-servers 192.223.1.2, 192.223.1.3;
     option domain-name "K24.com";
     option domain-search "K24.com";
     ```

4. **Pembuatan Skrip Konfigurasi**:
   Seluruh langkah otomatisasi disimpan di `/root/nomer5_config.sh` pada node tengen.

   Cuplikan konfigurasi subnet Network 3 pada `/etc/dhcp/dhcpd.conf`:
   ```text
   class "short-lease-team" {
       match pick-first-value (option dhcp-client-identifier, hardware);
   }
   subclass "short-lease-team" 1:02:42:6e:c3:10:00;       # ino
   subclass "short-lease-team" 1:02:42:cf:96:66:00;   # kusakabe

   class "long-lease-team" {
       match pick-first-value (option dhcp-client-identifier, hardware);
   }
   subclass "long-lease-team" 1:02:42:38:9a:92:00;       # miwa

   subnet 192.223.3.0 netmask 255.255.255.0 {
       option routers 192.223.3.1;
       option subnet-mask 255.255.255.0;
       option broadcast-address 192.223.3.255;
       option domain-name-servers 192.223.1.2, 192.223.1.3;
       option domain-name "K24.com";
       option domain-search "K24.com";

       pool {
           allow members of "short-lease-team";
           deny members of "long-lease-team";
           range 192.223.3.10 192.223.3.89;
           default-lease-time 1800;
           max-lease-time 1800;
       }

       pool {
           allow members of "long-lease-team";
           deny members of "short-lease-team";
           range 192.223.3.100 192.223.3.199;
           default-lease-time 43200;
           max-lease-time 43200;
       }
   }
   ```

### Cara Melakukan Validasi

1. **Uji Short Lease pada ino**:
   * Pada node **ino**, jalankan `/root/nomer5_client_test.sh`. Diperoleh IP `192.223.3.10` dengan durasi sewa `lease time 1800` detik (30 menit).
   ![Validasi Short Lease pada ino](assets/soal5_ino_short_lease.png)

2. **Uji Short Lease pada kusakabe**:
   * Pada node **kusakabe**, jalankan `/root/nomer5_client_test.sh`. Diperoleh IP `192.223.3.11` dengan durasi sewa `lease time 1800` detik (30 menit).
   ![Validasi Short Lease pada kusakabe](assets/soal5_kusakabe_short_lease.png)

3. **Uji Long Lease pada miwa**:
   * Pada node **miwa**, jalankan `/root/nomer5_client_test.sh`. Diperoleh IP `192.223.3.100` dengan durasi sewa `lease time 43200` detik (12 jam).
   ![Validasi Long Lease pada miwa](assets/soal5_miwa_long_lease.png)

4. **Uji Opsi DNS dan Domain Search**:
   * Jalankan `cat /etc/resolv.conf` pada node miwa. Output menampilkan `search K24.com`, `nameserver 192.223.1.2`, dan `nameserver 192.223.1.3`.
   ![Validasi resolv.conf pada miwa](assets/soal5_resolv_conf.png)

---

### Soal 6

> Kugisaki ditetapkan sebagai personel VIP yang harus mempertahankan alamat yang sama setiap kali terhubung. Buat DHCP static lease berdasarkan MAC Address client tersebut dengan fixed address [PREFIX IP].3.99. Pastikan alamat ini berada di luar seluruh pool dinamis, validasi konfigurasi server, lalu renew lease pada client. Buktikan bahwa alamat yang diterima sesuai dengan reservasi.

### Maksud dari Soal No. 6
Soal ini menguji konfigurasi **DHCP Static Lease** (*Reservation / Fixed Address*) untuk perangkat khusus atau personel VIP (**kugisaki**). Perangkat VIP wajib selalu menerima alamat IP yang sama persis (`192.223.3.99`) setiap kali menyalakan perangkat atau meminta pembaruan lease. Sesuai instruksi soal, alamat `192.223.3.99` wajib berada di luar seluruh rentang pool dinamis (yaitu di luar pool short lease `3.10-3.89` dan di luar pool long lease `3.100-3.199`). Hal ini menjamin bahwa alamat IP VIP tidak akan pernah dialokasikan secara tidak sengaja kepada klien umum lainnya.

### Cara Mengerjakan

1. **Identifikasi MAC Address VIP**:
   * MAC Address kugisaki: `02:42:0b:96:7a:00`

2. **Deklarasi Host pada `/etc/dhcp/dhcpd.conf`**:
   Di dalam blok subnet `192.223.3.0`, tambahkan deklarasi `host kugisaki`:
   ```text
   host kugisaki {
       hardware ethernet 02:42:0b:96:7a:00;
       fixed-address 192.223.3.99;
   }
   ```

3. **Pembuatan Skrip Konfigurasi dan Uji**:
   * Skrip konfigurasi server: disimpan di `/root/nomer6_config.sh` pada tengen.
   * Skrip uji mandiri client: disimpan di `/root/nomer6_client_test.sh` pada kugisaki dan seluruh client.
   * Skrip verifikasi server: disimpan di `/root/nomer6_test.sh` pada tengen.

### Cara Melakukan Validasi

1. **Pemeriksaan Konfigurasi Server tengen**:
   * Jalankan `grep -A 4 "host kugisaki" /etc/dhcp/dhcpd.conf` pada tengen untuk membuktikan deklarasi static lease sudah aktif.
   ![Konfigurasi host kugisaki pada tengen](assets/soal6_kugisaki_dhcpd_config.png)

2. **Uji Alokasi IP pada kugisaki**:
   * Jalankan `/root/nomer6_client_test.sh` pada console node **kugisaki**.
   * Buktikan alamat IP yang diperoleh adalah tepat `192.223.3.99/24` dengan gateway `192.223.3.1` dan ping internet berhasil.
   ![Validasi Fixed Address kugisaki](assets/soal6_kugisaki_fixed_ip.png)

3. **Uji Isolasi pada Client Lain (Negative Testing)**:
   * Jalankan `/root/nomer6_client_test.sh` pada client lain di Network 3 (misal **ino**).
   * Buktikan bahwa node ino tidak mendapatkan `192.223.3.99`, melainkan IP dari pool dinamisnya (`192.223.3.10`), sehingga IP VIP terisolasi sempurna.
   ![Uji Isolasi IP VIP pada Node ino](assets/soal6_ino_isolation_test.png)

---

### Soal 7

> Setelah aturan alokasi diterapkan, pastikan setiap client menerima konfigurasi jaringan sesuai wilayahnya: subnet mask 255.255.255.0 (/24), gateway dan broadcast address yang benar, DNS [PREFIX IP].1.2 serta [PREFIX IP].1.3, dan domain-search yang ditentukan. Periksa IP address dan routing seluruh client Divisi A dan Divisi B, kemudian cocokkan lease dengan /var/lib/dhcp/dhcpd.leases pada tengen. Pastikan tidak ada alamat yang bertabrakan atau berada di luar kebijakan pool.

### Maksud dari Soal No. 7
Soal ini merupakan tahap audit, verifikasi menyeluruh, dan rekonsiliasi data alokasi IP antara sisi server dengan seluruh klien di Divisi A dan Divisi B (total 8 client). Diperlukan pembuktian bahwa:
1. Seluruh parameter jaringan (IP, Netmask `/24`, Default Gateway, Broadcast Address, DNS resolver, dan domain search) telah diterima secara lengkap dan benar oleh setiap klien.
2. Seluruh alokasi sewa aktif yang tercatat pada file database sewa server (`/var/lib/dhcp/dhcpd.leases`) sinkron dengan IP aktual pada klien.
3. Tidak ada tabrakan IP (*IP conflict*) maupun pelanggaran batas rentang pool (*pool out-of-bounds*).

### Cara Mengerjakan

1. **Pemeriksaan Database Lease pada tengen**:
   Membaca dan memverifikasi isi database sewa `/var/lib/dhcp/dhcpd.leases` pada node tengen:
   ```bash
   cat /var/lib/dhcp/dhcpd.leases
   ```

2. **Eksekusi Pengujian Otomatis pada Seluruh Client**:
   Menjalankan skrip pengujian `/root/nomer7_client_test.sh` pada kedelapan klien:
   * Tim Divisi A: `itadori`, `fushiguro`, `zenin`, `okkotsu`
   * Tim Divisi B: `ino`, `kusakabe`, `miwa`, `kugisaki`

   Isi skrip `/root/nomer7_client_test.sh`:
   ```bash
   #!/bin/sh
   # Verifikasi Konfigurasi Jaringan & Routing Lengkap
   ip addr flush dev eth0
   udhcpc -i eth0 -n -q
   echo "=== [1] FLUSH & REQUEST LEASE ==="
   echo "=== [2] IP & BROADCAST ==="
   ip -br a show dev eth0
   ip addr show dev eth0
   echo "=== [3] ROUTING ==="
   ip route show
   echo "=== [4] DNS & SEARCH ==="
   cat /etc/resolv.conf
   echo "=== [5] PING GATEWAY ==="
   ping -c 2 $(ip route show default | awk '{print $3}')
   echo "=== [6] PING INTERNET ==="
   ping -c 2 8.8.8.8
   ```

### Cara Melakukan Validasi

1. **Audit Lengkap Klien Divisi A (itadori, fushiguro, zenin, okkotsu)**:
   * **itadori**: IP `192.223.2.10/24`, brd `192.223.2.255`, gw `192.223.2.1`.
   ![Audit Klien itadori](assets/soal7_itadori_audit.png)
   * **fushiguro**: IP `192.223.2.11/24`, brd `192.223.2.255`, gw `192.223.2.1`.
   ![Audit Klien fushiguro](assets/soal7_fushiguro_audit.png)
   * **zenin**: IP `192.223.2.70/24`, brd `192.223.2.255`, gw `192.223.2.1`.
   ![Audit Klien zenin](assets/soal7_zenin_audit.png)
   * **okkotsu**: IP `192.223.2.71/24`, brd `192.223.2.255`, gw `192.223.2.1`.
   ![Audit Klien okkotsu](assets/soal7_okkotsu_audit.png)

2. **Audit Lengkap Klien Divisi B (ino, kusakabe, miwa, kugisaki)**:
   * **ino**: IP `192.223.3.10/24`, brd `192.223.3.255`, gw `192.223.3.1`, lease 1800s.
   ![Audit Klien ino](assets/soal7_ino_audit.png)

3. **Verifikasi Database Lease pada Server tengen**:
   * Seluruh sewa aktif tercatat rapi pada `/var/lib/dhcp/dhcpd.leases` dan sinkron dengan IP aktual pada klien tanpa ada tabrakan alamat.
   ![Isi Database dhcpd.leases pada tengen](assets/soal7_dhcpd_leases.png)

---

### Soal 8

> Sebelum Curtain dibuka kembali, buktikan bahwa proses pemberian alamat berjalan sesuai protokol. Lakukan packet capture saat salah satu client Network 2 atau Network 3 meminta lease baru. Gunakan tcpdump pada tengen atau jalur menuju Data Center untuk menunjukkan urutan DHCPDISCOVER -> DHCPOFFER -> DHCPREQUEST -> DHCPACK. Identifikasi alamat server, alamat yang diberikan, lease time, dan field giaddr. Pastikan nilai giaddr sesuai dengan interface jichi yang menerima request dari subnet client.

### Maksud dari Soal No. 8
Soal ini bertujuan untuk membuktikan mekanisme kerja protokol DHCP secara mendalam pada level paket (Layer 3 dan Layer 7) melalui teknik penangkapan paket (*packet capture* / `tcpdump`). Praktikan harus mendokumentasikan siklus empat langkah protokol DHCP yang dikenal sebagai **DORA**:
1. **DHCPDISCOVER**: Klien membroadcast permintaan mencari server DHCP.
2. **DHCPOFFER**: Server menawarkan konfigurasi alamat IP ke klien.
3. **DHCPREQUEST**: Klien menerima tawaran dan meminta sewa resmi.
4. **DHCPACK**: Server mengonfirmasi pemberian hak sewa.

Khusus untuk jaringan yang menggunakan DHCP Relay, paket DISCOVER dan REQUEST yang sampai ke server memuat informasi khusus pada field **`giaddr` (Gateway IP Address)**. Nilai `giaddr` ini wajib cocok dengan IP interface router jichi tempat client terhubung (`192.223.2.1` untuk Network 2 atau `192.223.3.1` untuk Network 3).

### Cara Mengerjakan

1. **Pemasangan `tcpdump`**:
   Memastikan utilitas `tcpdump` terpasang pada server tengen.

2. **Eksekusi Penangkapan Paket**:
   * Menjalankan `tcpdump` pada interface `eth0` server tengen dengan filter port DHCP (`port 67 or port 68`) dan menyimpan hasilnya ke file PCAP `/root/nomer8_capture.pcap`.
   * Pada saat bersamaan, memicu request baru dari salah satu client (misal `itadori` di Network 2 atau `ino` di Network 3).

3. **Pembuatan Skrip Otomatisasi**:
   Seluruh prosedur disimpan di `/root/nomer8_config.sh` pada node tengen.

   Isi skrip `/root/nomer8_config.sh` pada node **tengen**:
   ```bash
   #!/bin/bash
   # Packet Capture Proses DHCP DORA pada tengen

   PCAP_FILE="/root/nomer8_capture.pcap"
   echo "[*] Memulai tcpdump menangkap paket DHCP..."
   tcpdump -i eth0 -n -vvv -c 4 "port 67 or port 68" -w "$PCAP_FILE" 2>&1 &
   TCPDUMP_PID=$!
   sleep 1

   echo "[+] tcpdump aktif dengan PID: $TCPDUMP_PID. Silakan jalankan udhcpc pada client."
   ```

### Cara Melakukan Validasi

1. **Penangkapan Paket DORA Network 2 (itadori)**:
   * Memicu permintaan DHCP dari itadori dengan `/root/nomer8_client_request.sh`.
   ![Eksekusi Permintaan DHCP pada itadori](assets/soal8_itadori_request.png)
   * Hasil tangkapan tcpdump pada tengen menampilkan 4 paket lengkap (Discover, Offer, Request, ACK), dengan:
     * **`Gateway-IP (giaddr)`**: `192.223.2.1` (Interface `eth2` jichi).
     * **`Your-IP`**: `192.223.2.10`.
     * **`Server-ID`**: `192.223.4.10`.
   ![Hasil tcpdump Siklus DORA Network 2](assets/soal8_tcpdump_net2.png)

2. **Penangkapan Paket DORA Network 3 (ino)**:
   * Memicu permintaan DHCP dari ino dengan `/root/nomer8_client_request.sh`.
   ![Eksekusi Permintaan DHCP pada ino](assets/soal8_ino_request.png)
   * Hasil tangkapan tcpdump pada tengen menampilkan 4 paket lengkap, dengan:
     * **`Gateway-IP (giaddr)`**: `192.223.3.1` (Interface `eth3` jichi).
     * **`Your-IP`**: `192.223.3.10`.
     * **`Lease-Time`**: `1800` detik (Short Lease).
     * **`Domain-Name`**: `K24.com`.
   ![Hasil tcpdump Siklus DORA Network 3](assets/soal8_tcpdump_net3.png)

---

### Soal 9

> Sebuah gangguan memutus jalur relay dan membuat permintaan alamat tidak sampai ke Data Center. Hentikan service DHCP Relay pada jichi, lalu paksa salah satu client di Network 2 atau Network 3 meminta lease baru dan catat gejalanya. Pulihkan service relay, ulangi permintaan DHCP, lalu buktikan bahwa client kembali memperoleh alamat dari pool yang benar dengan gateway semula.

### Maksud dari Soal No. 9
Soal ini bertujuan untuk menguji keandalan sistem (*reliability test*) serta mendokumentasikan gejala gangguan (*failure symptoms*) ketika terjadi putusnya layanan DHCP Relay. Praktikan harus membuktikan bahwa ketiadaan agen relay menyebabkan paket broadcast penemuan alamat dari client tidak dapat mencapai server di Data Center, sehingga client mengalami kegagalan (*DHCP timeout*). Selanjutnya, praktikan harus membuktikan bahwa setelah layanan relay dipulihkan kembali, seluruh proses alokasi alamat kembali normal tanpa distorsi konfigurasi rute maupun gateway.

### Cara Mengerjakan

1. **Simulasi Pemutusan Layanan (Relay Outage)**:
   * Menghentikan proses `dhcrelay` pada router jichi dengan perintah `/root/nomer9_config.sh stop`.
   * Pada node client (misal `itadori`), melepaskan IP lama dan mencoba meminta lease baru dengan `/root/nomer9_client_test.sh`.
   * Mencatat gejala kegagalan yang terjadi.

2. **Pemulihan Layanan (Relay Recovery)**:
   * Menjalankan kembali daemon relay pada router jichi dengan `/root/nomer9_config.sh start`.
   * Mengulangi permintaan DHCP pada node client.

3. **Pembuatan Skrip Simulasi**:
   Disimpan di `/root/nomer9_config.sh` pada router jichi.

   Isi skrip `/root/nomer9_config.sh` pada node **jichi**:
   ```bash
   #!/bin/bash
   # Skrip Pengujian Outage dan Recovery DHCP Relay

   ACTION=$1

   if [ "$ACTION" = "stop" ]; then
       echo "[*] Menghentikan service DHCP Relay..."
       killall dhcrelay 2>/dev/null
       echo "[+] Status setelah dihentikan:"
       echo "[-] dhcrelay TIDAK AKTIF (Berhasil Dihentikan)"
   elif [ "$ACTION" = "start" ]; then
       echo "[*] Memulihkan / Menjalankan service DHCP Relay..."
       killall dhcrelay 2>/dev/null
       /usr/sbin/dhcrelay -q -i eth2 -i eth3 -i eth4 192.223.4.10
       echo "[+] Status setelah dipulihkan:"
       ps aux | grep dhcrelay
   else
       echo "Penggunaan: $0 {stop|start}"
   fi
   ```

### Cara Melakukan Validasi

1. **Dokumentasi Penghentian Relay pada jichi**:
   * Menjalankan `/root/nomer9_config.sh stop` pada router jichi.
   ![Penghentian DHCP Relay pada jichi](assets/soal9_relay_stop.png)

2. **Dokumentasi Gejala Kegagalan pada Klien (Outage)**:
   * Menjalankan `/root/nomer9_client_test.sh` pada itadori.
   * Terjadi timeout: `udhcpc: no lease, failing`, status IP kosong, dan uji ping menghasilkan error `ping: connect: Network unreachable`.
   ![Gejala Kegagalan Klien Saat Relay Putus](assets/soal9_relay_outage_fail.png)

3. **Dokumentasi Pemulihan Relay pada jichi**:
   * Menjalankan `/root/nomer9_config.sh start` pada router jichi.
   * Service kembali aktif pada interface `eth2`, `eth3`, `eth4`.
   ![Pemulihan Layanan DHCP Relay pada jichi](assets/soal9_relay_start.png)

4. **Dokumentasi Pemulihan Konektivitas pada Klien (Recovery)**:
   * Menjalankan kembali `/root/nomer9_client_test.sh` pada itadori.
   * Klien langsung berhasil memperoleh kembali lease IP `192.223.2.10`, gateway `192.223.2.1`, dan ping internet pulih normal (0% packet loss).
   ![Pemulihan Sukses pada Klien itadori](assets/soal9_relay_recovery_success.png)

---

### Soal 10

> Setelah gangguan Shibuya tertangani, pastikan pemulihan bertahan setelah restart. Aktifkan autostart DHCP Server pada tengen dan DHCP Relay pada jichi, lalu restart kedua node. Verifikasi status layanan, IP, gateway, lease, dan konektivitas client Network 2-3. Pastikan kebijakan Pool 1, Pool 2, short lease, long lease, dan fixed address tetap berlaku.

### Maksud dari Soal No. 10
Pada lingkungan virtualisasi container (khususnya Docker di GNS3), proses container dapat kehilangan *state* runtime, interface virtual, atau proses background ketika node dimatikan (*Stop*) atau direstart (*Reload*). Soal ini menuntut implementasi mekanisme **Autostart yang Tangguh dan Persisten** pada kedua node infrastruktur utama (**jichi** dan **tengen**). Layanan DHCP Relay pada jichi dan DHCP Server pada tengen harus otomatis aktif kembali saat container booting tanpa memerlukan intervensi manual. Selain itu, dependensi paket Debian disimpan secara lokal (*offline cache*) agar node dapat memulihkan diri meskipun akses internet ke repositori eksternal belum siap.

### Cara Mengerjakan

1. **Implementasi Offline Package Caching**:
   Menyimpan file arsip `.deb` paket `isc-dhcp-server` dan `isc-dhcp-relay` ke direktori lokal `/root/cache/` pada masing-masing node. Dengan demikian, proses instalasi ulang dapat dilakukan secara lokal tanpa bergantung pada repositori eksternal saat booting.

2. **Konfigurasi Autostart Router jichi**:
   * Membuat skrip `/root/nomer10_config.sh` yang menetapkan seluruh IP interface `eth0`-`eth4`, default route, forwarding, NAT, dan menyalakan daemon `dhcrelay`.
   * Memasang pemanggilan skrip tersebut ke dalam entry point inisialisasi Debian `/root/init.sh` dan `/etc/debinet-init.sh`, serta `/root/.bashrc`.

3. **Konfigurasi Autostart Server tengen**:
   * Membuat skrip `/root/nomer10_config.sh` yang menetapkan IP `192.223.4.10`, default route ke `192.223.4.1`, menulis konfigurasi lengkap `/etc/dhcp/dhcpd.conf` (seluruh scope Soal 2, 4, 5, 6), dan menyalakan service `isc-dhcp-server`.
   * Memasang pemanggilan skrip tersebut ke dalam `/root/init.sh`, `/etc/debinet-init.sh`, dan `/root/.bashrc`.

4. **Pembuatan Skrip Konfigurasi Autostart**:
   * jichi: `/root/nomer10_config.sh`
   * tengen: `/root/nomer10_config.sh`

   Isi file `/root/init.sh` pada jichi dan tengen:
   ```bash
   #!/bin/sh
   /root/nomer10_config.sh
   ```

### Cara Melakukan Validasi

1. **Verifikasi Autostart pada tengen Pasca Restart**:
   * Setelah node tengen dinyalakan kembali, buka console dan periksa proses dengan `ps aux | grep dhcpd`.
   * Daemon `dhcpd` langsung aktif berjalan secara otomatis tanpa intervensi perintah manual.
   ![Autostart Service isc-dhcp-server pada tengen](assets/soal10_tengen_autostart.png)

2. **Verifikasi Autostart pada jichi Pasca Restart**:
   * Setelah node jichi dinyalakan kembali, buka console dan periksa proses dengan `ps aux | grep dhcrelay`.
   * Daemon `dhcrelay` langsung aktif berjalan secara otomatis meneruskan traffic interface `eth2`, `eth3`, `eth4`.
   ![Autostart Service dhcrelay pada jichi](assets/soal10_jichi_autostart.png)

3. **Verifikasi Rekapitulasi Menyeluruh Klien Pasca Restart**:
   * Jalankan `cat /root/nomer10_verifikasi.log` pada tengen untuk melihat tabel hasil audit pasca restart.
   * Seluruh 8 klien (itadori, fushiguro, zenin, okkotsu, ino, kusakabe, miwa, kugisaki) berstatus **SESUAI**, tidak ada tabrakan IP, dan seluruh kebijakan pool bertahan secara konsisten.
   ![Log Rekapitulasi Hasil Verifikasi Soal 10 Pasca Restart](assets/soal10_rekapitulasi_log.png)
