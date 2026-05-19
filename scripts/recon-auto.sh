#!/bin/bash

# ==========================================
# Recon Automation Script by Hanif
# ==========================================

# Membuat Timestamp untuk nama file yang unik (Format: TahunBulanTanggal_JamMenitDetik)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Definisi Path 
BASE_DIR=$(pwd)
INPUT_FILE="$BASE_DIR/input/domains.txt"
OUTPUT_ALL="$BASE_DIR/output/all-subdomains_$TIMESTAMP.txt"
OUTPUT_LIVE="$BASE_DIR/output/live_$TIMESTAMP.txt"
LOG_PROG="$BASE_DIR/logs/progress_$TIMESTAMP.log"
LOG_ERR="$BASE_DIR/logs/errors_$TIMESTAMP.log"

# Logging dengan timestamp dan tee
log_progress() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_PROG"
}

log_progress "Memulai proses Recon Automation..."
log_progress "Sesi eksekusi: $TIMESTAMP"

# 1. Validasi Tools
for tool in subfinder httpx anew; do
    if ! command -v $tool &> /dev/null; then
        log_progress "CRITICAL ERROR: Tool '$tool' belum siap."
        exit 1
    fi
done

# 2. Validasi Input
if [[ ! -f "$INPUT_FILE" ]]; then
    log_progress "CRITICAL ERROR: File $INPUT_FILE tidak ditemukan!"
    exit 1
fi

# 3. Subdomain Enumeration
log_progress "Memulai enumerasi subdomain untuk domain di $INPUT_FILE"

while read -r domain; do
    [[ -z "$domain" ]] && continue
    
    log_progress "Menjalankan subfinder untuk: $domain"
    
    # Menjalankan subfinder dan memfilter duplikasi dengan anew
    subfinder -d "$domain" -silent 2>>"$LOG_ERR" | anew "$OUTPUT_ALL" > /dev/null
    
    log_progress "Selesai memproses domain: $domain"
done < "$INPUT_FILE"

# 4. Filter Live Hosts dengan HTTPX
log_progress "Memulai pengecekan live hosts menggunakan httpx..."

# httpx dengan flag -sc dan -title
# anew digunakan untuk mencegah duplikasi hasil live hosts
cat "$OUTPUT_ALL" | httpx -sc -title -silent 2>>"$LOG_ERR" | anew "$OUTPUT_LIVE" > /dev/null

# 5. Hasil Akhir
TOTAL_SUB=$(wc -l < "$OUTPUT_ALL" 2>/dev/null || echo "0")
TOTAL_LIVE=$(wc -l < "$OUTPUT_LIVE" 2>/dev/null || echo "0")

log_progress "=========================================="
log_progress "Recon Selesai!"
log_progress "Total Subdomain Unik Ditemukan : $TOTAL_SUB"
log_progress "Total Live Hosts Aktif         : $TOTAL_LIVE"
log_progress "File All Subdomains disimpan di: $OUTPUT_ALL"
log_progress "File Live Hosts disimpan di    : $OUTPUT_LIVE"
log_progress "=========================================="
