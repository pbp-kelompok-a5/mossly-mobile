# Community — Checkpoint 1

Halaman Community membaca data asli dari API Django memakai `ApiClient` bersama.
Token berasal dari `Session`; modul ini tidak menyimpan token atau alamat server.

## Endpoint

- `GET /api/v1/community/threads/?category=&author=&page=` untuk feed.
- `GET /api/v1/community/threads/<id>/` untuk detail.

`ApiClient` sudah menambahkan `/api/v1`, sehingga service memakai path
`/community/threads/` dan `/community/threads/<id>/` dengan trailing slash.

Feed berisi `category`, `results`, dan `pagination`. Pagination mengikuti
`page`, `total_pages`, `has_next`, dan `has_previous` dari backend. Thread berisi
identitas publik `author`, judul, isi, kategori, tanggal ISO, `is_auto_post`,
`like_count`, `reply_count`, dan `is_liked`. Avatar `sprout`, `leaf`, dan `tree`
ditampilkan sebagai ikon Material.

## Alur kode

- `models/`: `fromJson` memvalidasi tipe respons sebelum data ditampilkan.
- `services/community_service.dart`: request GET melalui klien dari
  `context.read<ApiClient>()`, batas waktu 20 detik, dan pesan kegagalan.
- `pages/community_page.dart`: menyimpan Future dalam State, lalu memakai
  FutureBuilder untuk memuat feed. `Visibility.of(context)` menunda request
  pertama sampai tab Community terlihat di IndexedStack milik HomeShell.
  Berpindah tab mempertahankan data yang sudah dimuat.
  Filter mengulang dari halaman satu;
  tombol sebelumnya/selanjutnya mengikuti metadata API.
- `pages/thread_detail_page.dart`: mengetuk kartu membuka route detail dan
  mengambil ulang data lengkap berdasarkan ID thread.
- `widgets/`: kartu, penulis, label kategori, jumlah apresiasi/balasan,
  dan keadaan kosong/gagal. Warna dari ColorScheme, jarak dari MosslySpace.

RefreshIndicator menunggu request selesai dan tetap bisa dipakai pada feed
kosong atau gagal. Error jaringan, timeout, respons rusak, dan status HTTP
ditampilkan dengan pesan serta tombol coba lagi. FutureBuilder mengabaikan
respons request lama setelah filter berubah. Controller dibersihkan di dispose.

Pada CP1, jumlah like/balasan dan status like hanya ditampilkan. Form membuat
thread, edit/hapus, mengirim balasan, serta aksi like menunggu endpoint lanjutan.
Post achievement otomatis dapat dibaca dan memiliki label tersendiri.

## Menjalankan

Login dengan akun yang terdaftar di server yang sama. Default server mengikuti
`lib/core/config.dart`. Untuk emulator Android dengan Django lokal, jalankan
Django pada `0.0.0.0:8000` dan Flutter dengan
`--dart-define=API_BASE_URL=http://10.0.2.2:8000`.
Untuk Chrome/iOS Simulator di komputer yang sama gunakan
`--dart-define=API_BASE_URL=http://127.0.0.1:8000`.
Sesuaikan ALLOWED_HOSTS backend bila server lokal menolak host emulator.

## AI Disclosure

Implementasi model, service GET, halaman feed/detail, dan widget Community
dibantu Codex berdasarkan API_GUIDE.md dan PROMPTS.md. Kontrak JSON dicocokkan
dengan respons API Django lokal. Anggota modul tetap perlu meninjau perubahan,
memahami alur async, dan memverifikasi tampilan pada perangkat sebelum demo.
