## Recon Automation

## Deskripsi Proyek
Proyek ini adalah script Bash otomatisasi proses reconnaissance yang berjalan secara *end-to-end* tanpa error. Script ini mengintegrasikan 3 tools recon utama (**subfinder**, **httpx**, dan **anew**) ke dalam satu *pipeline* yang efisien. 

---

##  Setup Environment & Instalasi Tools
Berikut adalah langkah-langkah instalasi *environment* dan *tools* pendukung:

### 1. Konfigurasi Go Environment (PATH)
Pastikan direktori instalasi Go sudah masuk ke dalam PATH. Tambahkan konfigurasi berikut ke terminal:
```bash
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
source ~/.zshrc
```

### 2. Install ProjectDiscovery Tools Manager (PDTM)
```bash
go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
```

### 3. Install Subfinder dan HTTPX 
```bash
pdtm -i subfinder,httpx
```

### 4. Install Anew 
```bash
go install -v github.com/tomnomnom/anew@latest
```

---

##  Cara Menjalankan Script

1. Masukkan minimal 5 target domain ke dalam file input:
   `input/domains.txt`
2. Berikan izin eksekusi (*executable*) pada script:
   ```bash
   chmod +x scripts/recon-auto.sh
   ```
3. Jalankan script dari direktori utama proyek:
   ```bash
   ./scripts/recon-auto.sh
   ```

---

##  Contoh Input & Output

### Contoh Input (`input/domains.txt`)
```text
uber.com
starbucks.com
expressvpn.com
hackerone.com
bugcrowd.com
tesla.com
redbull.com
```

### Contoh Output Akhir (`output/live_[TIMESTAMP].txt`)
```text
https://sdcatalogadmin.starbucks.com [302]
https://wildcard.microsites03.redbull.com [200] [Red Bull Media House Webhosting]
https://akamai-apigateway-charging-ownership.tesla.com [503] [Service Unavailable]
https://api.hackerone.com [200] [HackerOne API]
https://xlb.uber.com [302] [302 Found]
```

---

##  Penjelasan Singkat Bagian Kode

Berikut adalah logika dan alur dari script `recon-auto.sh`:

* **Pembuatan Timestamp:** Menggunakan `date +"%Y%m%d_%H%M%S"` untuk menghasilkan penamaan file output dan log yang dinamis dan unik setiap kali script dijalankan.
* **Logging System:** Fungsi `log_progress` menggunakan kombinasi `echo` (untuk menampilkan *output* di layar dengan penambahan penanda waktu) dan `tee -a` (untuk menyalin *output* layar tersebut ke dalam file log secara permanen).
* **Validasi Tools & Input:** Menggunakan `command -v` untuk memastikan semua tool (subfinder, httpx, anew) tersedia, dan memeriksa keberadaan file `domains.txt`. Jika gagal, script otomatis berhenti (`exit 1`).
* **Subfinder (Enumerasi) & Anew:** Membaca target per baris (looping). Subfinder mencari subdomain, lalu error di-*redirect* ke `errors.log` (`2>>`). Hasil output di-*pipe* (`|`) ke `anew` untuk memastikan hanya subdomain unik yang disimpan.
* **HTTPX (Live Host Filter):** Membaca hasil subdomain, lalu HTTPX mencari host yang aktif dengan menambahkan argumen `-sc` (Status Code) dan `-title`. Hasilnya kembali disaring menggunakan `anew` ke file *output live*.

---

##  Screenshot Hasil Eksekusi

### 1. Terminal Eksekusi
<img width="700" alt="running" src="https://github.com/user-attachments/assets/b31aab99-60ac-4099-a060-2e6dc1f7689f" />
<img width="700"  alt="result" src="https://github.com/user-attachments/assets/33f9f64a-45ec-4c76-9499-d172423255eb" />

Proses Eksekusi Script 
Alur Berjalan Sesuai Rencana: Script membaca file domains.txt dan mengeksekusi subfinder untuk setiap domain satu per satu. Setelah subfinder selesai, script melanjutkan ke tahap pengecekan live host dengan httpx.


### 2. Hasil Output `live.txt`
<img width="700" alt="live1" src="https://github.com/user-attachments/assets/a418fab8-fe5d-4a55-a7da-65e3b6257102" />
<img width="700" alt="live2" src="https://github.com/user-attachments/assets/d1071370-b837-4480-96f2-2d7777fd11bd" />
 
Output dari httpx sangat rapi dan sesuai ekspektasi. Bisa melihat URL lengkap dengan http:// atau https://, diikuti oleh HTTP Status Code seperti [200], [302], [403], [404], dan judul halaman web.
