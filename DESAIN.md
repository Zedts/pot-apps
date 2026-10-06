# DOKUMENTASI DESAIN & SPESIFIKASI SYSTEM POT (PRESENSI OLEH-OLEH TURKI)

## 1. DOKUMENTASI UMUM & IDENTITAS VISUAL

### 1.1 Branding & Visual Identity
- **Nama Aplikasi**: POT - Presensi Oleh² Turki
- **Tagline**: Stok Aman, Kerja Nyaman, Gaji Tepat (Satu Data, Semua Terhubung: Produksi • Pengiriman • Penjualan • Absensi • Payroll)
- **Skema Warna Utama (Red-White-Cream POT)**:
  - **Primary Red (Crimson/Bordeaux)**: `#990000` / `#A81B1B` / `#800000`
  - **Cream Background & Cards**: `#FFF8F0` / `#FDF6EE` / `#FAEDCD`
  - **Secondary White**: `#FFFFFF`
  - **Dark Slate Text & Headings**: `#1A1A1A` / `#2D3748`
  - **Status Colors**:
    - Selesai / Success: `#2E7D32` (Green)
    - Proses / Warning: `#D97706` (Amber/Orange)
    - Info / Blue: `#2563EB` (Indigo/Blue)
    - Danger / Error: `#DC2626` (Red)

### 1.2 Target Platform & User Roles
1. **Mobile SPG App (Prioritas Utama)**:
   - Target User: Sales Promotion Girl (SPG) di Lapak/Outlet.
   - Perangkat: Smartphone Android/iOS.
   - Fitur Utama: Login, Absen Masuk/Pulang (GPS), Terima Barang (Upload Nota), Stok & Penjualan (Tunai/QRIS/Transfer), Closing Harian (Hitung Fisik & Uang), Slip Gaji.
2. **Dashboard Web & Tablet (Admin / Produksi / Viar / Owner)**:
   - Target User: Owner, Admin, Tim Produksi, Tim Viar/Pengiriman.
   - Perangkat: Desktop / Web Browser / Tablet.
   - Fitur Utama: Dashboard Real-time Owner, Input & Status Pengiriman (Produksi), Konfirmasi Driver/Viar, Validasi Closing & Monitoring Lapak, Laporan Sales & Payroll.

---

## 2. ARSITEKTUR KODE & DESIGN PATTERN

### 2.1 Pattern: Feature-Based + Repository Pattern
Aplikasi menggunakan pola arsitektur **Feature-Based** yang terstruktur, rapi, dan mudah di-maintain:

```text
lib/
├── core/
│   ├── constants/        # Colors, Typography, Constants, Endpoints
│   ├── theme/            # POT Red-White-Cream ThemeData
│   ├── utils/            # Currency formatters, Date formatters, GPS helpers
│   ├── widgets/          # Reusable UI components (POT Buttons, Cards, Inputs, Shimmers, Error views)
│   └── services/         # Firebase service initializers, Storage, FCM
├── features/
│   ├── auth/
│   │   ├── models/       # UserModel, UserRole
│   │   ├── repositories/ # AuthRepository
│   │   ├── providers/    # AuthProvider / AuthNotifier
│   │   └── screens/      # LoginScreen
│   ├── beranda/
│   │   └── screens/      # SPGBerandaScreen, AdminDashboardScreen
│   ├── absensi/
│   │   ├── models/       # AbsensiModel
│   │   ├── repositories/ # AbsensiRepository
│   │   ├── providers/    # AbsensiProvider
│   │   └── screens/      # AbsensiScreen, RiwayatAbsensiScreen
│   ├── penerimaan/
│   │   ├── models/       # PenerimaanModel, PengirimanModel
│   │   ├── repositories/ # PenerimaanRepository
│   │   └── screens/      # TerimaBarangScreen, PengirimanWebScreen
│   ├── penjualan/
│   │   ├── models/       # ProdukModel, PenjualanModel, ItemKeranjangModel
│   │   ├── repositories/ # PenjualanRepository, ProdukRepository
│   │   └── screens/      # StokPenjualanScreen
│   ├── closing/
│   │   ├── models/       # ClosingModel
│   │   ├── repositories/ # ClosingRepository
│   │   └── screens/      # ClosingHarianScreen, ValidasiClosingWebScreen
│   └── payroll/
│       ├── models/       # PayrollModel, SlipGajiModel
│       ├── repositories/ # PayrollRepository
│       └── screens/      # SlipGajiScreen, RekapPayrollWebScreen
└── main.dart             # Entry point (Firebase init, Router/Auth Wrapper)
```

---

## 3. STRUKTUR DATA FIRESTORE (TABEL UTAMA)

### 3.1 Collections Schema & Typed Models

#### 1. `users`
- `id` (String): Document ID (Firebase Auth UID)
- `nama` (String): Nama lengkap user
- `role` (String): `'owner' | 'admin' | 'produksi' | 'viar' | 'spg'`
- `no_hp` (String): Nomor WhatsApp / Telepon
- `username` (String): Username login
- `lapak_id` (String?): ID Lapak tempat SPG bertugas
- `status` (String): `'aktif' | 'nonaktif'`
- `created_at` (Timestamp): Server timestamp

#### 2. `lapak`
- `id` (String): Document ID
- `nama` (String): Contoh: `"Lapak 2"`
- `lokasi` (String): Alamat / Koordinat GPS Lapak
- `keterangan` (String): Catatan tambahan
- `spg_id` (String?): ID SPG penanggungjawab aktif

#### 3. `produk`
- `id` (String): Document ID
- `nama` (String): Contoh: `"Mochi Sk"`, `"Cokdub 15k"`, `"Baklava Almond"`
- `harga` (double): Harga jual resmi
- `kategori` (String): Contoh: `"Mochi"`, `"Cokelat"`, `"Baklava"`
- `satuan` (String): `"pcs"`, `"pack"`
- `is_active` (bool): `true`

#### 4. `pengiriman` & `pengiriman_detail`
- `pengiriman` doc:
  - `id` (String): Document ID (contoh: `#PG-20260911-001`)
  - `tanggal` (String): YYYY-MM-DD
  - `lapak_id` (String): ID Lapak Tujuan
  - `created_by` (String): ID User Tim Produksi
  - `status` (String): `'draft' | 'dikirim_viar' | 'diterima_spg' | 'selesai'`
  - `created_at` (Timestamp): Server timestamp
- `items` (Array of Object): `[{ produk_id, nama_produk, qty_kirim, qty_terima }]`

#### 5. `penerimaan`
- `id` (String): Document ID
- `pengiriman_id` (String): Reference to `pengiriman.id`
- `spg_id` (String): ID SPG yang menerima
- `tanggal` (String): YYYY-MM-DD
- `nota_url` (String?): URL foto nota fisik dari Cloud Storage
- `catatan` (String): Catatan selisih (misal: "Barang kurang 1 pcs")
- `status` (String): `'sesuai' | 'selisih'`
- `created_at` (Timestamp): Server timestamp

#### 6. `stok_lapak` (Live Counter per Lapak & Produk)
- `id` (String): `{lapak_id}_{produk_id}`
- `lapak_id` (String)
- `produk_id` (String)
- `stok_awal` (int)
- `stok_masuk` (int)
- `stok_terjual` (int)
- `stok_akhir` (int)
- `updated_at` (Timestamp)

#### 7. `penjualan` & `penjualan_detail`
- `id` (String): Document ID
- `spg_id` (String): ID SPG
- `lapak_id` (String): ID Lapak
- `tanggal` (String): YYYY-MM-DD
- `total_harga` (double): Total nominal transaksi
- `metode_pembayaran` (String): `'tunai' | 'qris' | 'transfer'`
- `bukti_qris_url` (String?): Cloud Storage image URL jika QRIS/Transfer
- `catatan` (String?): Catatan opsional
- `items` (Array of Object): `[{ produk_id, nama_produk, qty, harga_satuan, subtotal }]`
- `created_at` (Timestamp): `FieldValue.serverTimestamp()`

#### 8. `absensi`
- `id` (String): Document ID
- `user_id` (String): ID User SPG
- `lapak_id` (String): ID Lapak tempat absen
- `tanggal` (String): YYYY-MM-DD
- `jam_masuk` (Timestamp?): Server timestamp saat Absen Masuk
- `jam_pulang` (Timestamp?): Server timestamp saat Absen Pulang
- `lokasi_masuk` (String?): Latitude, Longitude GPS
- `lokasi_pulang` (String?): Latitude, Longitude GPS
- `foto_masuk_url` (String?): URL Cloud Storage
- `status` (String): `'hadir' | 'terlambat' | 'izin'`
- `keterangan` (String?)

#### 9. `closing`
- `id` (String): Document ID (`{lapak_id}_{tanggal}`)
- `spg_id` (String): ID SPG
- `lapak_id` (String): ID Lapak
- `tanggal` (String): YYYY-MM-DD
- `stok_sistem` (int): Total unit sisa menurut catatan transaksi
- `stok_fisik` (int): Total unit sisa menurut hitungan fisik SPG
- `total_omset` (double): Total penjualan hari ini
- `tunai_sistem` (double): Total tunai tercatat sistem
- `qris_sistem` (double): Total QRIS tercatat sistem
- `transfer_sistem` (double): Total Transfer tercatat sistem
- `uang_tunai_fisik` (double): Uang fisik di kantong/laci SPG
- `selisih_stok` (int): `stok_fisik - stok_sistem`
- `selisih_uang` (double): `uang_tunai_fisik - tunai_sistem`
- `catatan` (String?)
- `status` (String): `'pending' | 'terverifikasi' | 'perlu_revisi'`
- `validated_by` (String?)
- `created_at` (Timestamp): `FieldValue.serverTimestamp()`

#### 10. `payroll` & `slip_gaji`
- `payroll` doc:
  - `id` (String): Document ID
  - `user_id` (String): ID User SPG
  - `periode` (String): `"YYYY-MM"` (contoh: `"2026-09"`)
  - `hari_kerja` (int): Jumlah hari hadir
  - `total_penjualan` (double): Total penjualan SPG dalam sebulan
  - `gaji_pokok` (double)
  - `bonus_penjualan` (double)
  - `lembur` (double)
  - `potongan` (double)
  - `kasbon` (double)
  - `total_gaji` (double)
  - `status` (String): `'draft' | 'published'`
  - `created_at` (Timestamp)

---

## 4. ATOMIC TRANSACTIONS & SECURITY RULES

### 4.1 Prinsip Keamanan & Integritas Data
1. **Jangan Percaya Client**: Client tidak boleh menentukan harga item atau menghitung total belanja tanpa verifikasi server/transaction.
2. **Atomic Stock Mutation**: Penjualan dan Penerimaan Barang mengubah `stok_lapak` menggunakan Firestore Transactions (`runTransaction`) atau Cloud Functions atomic updates.
3. **Server Timestamp Standard**: Semua data audit (absensi, transaksi penjualan, submit closing) wajib menggunakan `FieldValue.serverTimestamp()`.

---

## 5. ALUR BISNIS (BUSINESS FLOWCHART)

### 5.1 Alur Pengiriman & Penerimaan Barang
1. **Produksi**: Tim Produksi membuat pengiriman baru (`status: dikirim_viar`), memilih lapak tujuan dan mengisi daftar produk & qty.
2. **Viar (Pengiriman)**: Tim Viar mengonfirmasi barang yang dibawa.
3. **SPG**: Membuka menu **Terima Barang** di Mobile SPG -> Foto Nota Penerimaan -> Hitung fisik & input qty diterima -> Klik **Simpan Penerimaan**. Stok awal/masuk lapak diperbarui secara otomatis.

### 5.2 Alur Stok & Penjualan SPG
1. SPG membuka menu **Stok & Penjualan**.
2. Memilih produk, menentukan jumlah (+/-), memilih metode pembayaran (Tunai / QRIS / Transfer).
3. Jika QRIS/Transfer, upload foto bukti bayar.
4. Klik **Simpan Penjualan**. Sistem menjalankan **Firestore Transaction** untuk memutasi `stok_lapak.stok_terjual` dan `stok_akhir` secara atomic.

### 5.3 Alur Closing Harian & Verification
1. Di akhir shift, SPG membuka **Closing Harian**.
2. Sistem menampilkan ringkasan otomatis (Stok Awal, Terjual, Stok Akhir Sistem, Total Omset Tunai/QRIS/Transfer).
3. SPG memasukkan **Stok Fisik** dan **Uang Tunai Fisik**.
4. SPG mengirimkan Closing.
5. Admin/Owner memantau di **Dashboard Web** -> Memvalidasi closing -> Jika pas, status menjadi `terverifikasi`.

### 5.4 Alur Absensi GPS
1. SPG membuka menu **Absensi**.
2. Sistem mengambil koordinat GPS terkini.
3. SPG menekan **Absen Masuk** / **Absen Pulang**.
4. Timestamp server dicatat secara resmi.

---

## 6. STATEMANAGEMENT & OFFLINE RESILIENCE

1. **Typed State Models**:
   - `AsyncValue` / `StateNotifier` / Provider pattern untuk menangani state `loading`, `data`, `error`, `empty`, dan `offline`.
2. **Offline Local Cache**:
   - Firestore Persistence diaktifkan agar data produk dan stok lokal tetap dapat dibaca saat jaringan terputus.
3. **Error Handling Component**:
   - Semua layar menyertakan error boundary & visual state (misal `PotErrorWidget`, `PotEmptyWidget`, `PotLoadingWidget`).
