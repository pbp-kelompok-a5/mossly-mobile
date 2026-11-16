# 🌳 Mossly Mobile

Aplikasi mobile Mossly, dibangun dengan Flutter untuk Proyek Akhir Semester PBP (CSGE602022) Gasal 2026/2027. Ini adalah versi mobile dari situs web [Mossly](https://tania-ju-mossly.pws.cs.ui.ac.id/) (Proyek Tengah Semester).

## 📱 Deskripsi Aplikasi

**Mossly** membantu pengguna membangun gaya hidup berkelanjutan lewat pelacakan jejak karbon perjalanan, pengelolaan kebiasaan dan goal, pencapaian personal, dan komunitas. Nama Mossly diambil dari kata *moss*, lumut yang tumbuh perlahan namun konsisten: perubahan besar dimulai dari langkah kecil.

Di aplikasi mobile, pengguna dapat mencatat perjalanan dan melihat estimasi emisinya, melakukan check-in kebiasaan harian, memantau progres goal, melihat ringkasan dan badge di dashboard, serta berbagi di komunitas. Seluruh data sama dengan yang tampil di situs web.

## 👥 Kelompok A-05

| Nama | NPM | Modul |
| --- | --- | --- |
| Fildza Hasnalia Nabila | 2506625003 | Personal Sustainability Dashboard |
| Sheva Aquila Mahardika | 2506622033 | Login & Onboarding |
| Tania Ju | 2506608123 | Sustainable Habit & Goal Tracker |
| Callysta Arviana | 2506619045 | Carbon Footprint Tracker |
| Isybal Sama Eleazar Malau | 2506623963 | Sustainability Community |

## 🧩 Modul dan Pembagian Kerja

Setiap anggota melanjutkan modul yang sama dengan Proyek Tengah Semester, yang mencakup endpoint Django REST Framework di proyek web dan halaman Flutter di repositori ini.

1. **Login & Onboarding**  
*Dikerjakan oleh Sheva Aquila Mahardika*  
Tab **Profil** · `lib/features/accounts/`  
Modul ini menangani registrasi, login, logout, serta pengelolaan sesi berbasis token untuk menjaga status autentikasi pengguna. Tersedia juga *onboarding form* setelah menyelesaikan registrasi untuk menyesuaikan data awal untuk input bagian tracker nantinya. Modul ini juga akan menyediakan data identitas yang diambil untuk tampilan di modul *Sustainability Community*.
2. **Carbon Footprint Tracker**  
*Dikerjakan oleh Callysta Arviana*  
Tab **Karbon** · `lib/features/carbon/`  
Modul ini memungkinkan pengguna mencatat perjalanan sehari-hari dan menghitung estimasi emisi karbon yang dihasilkan. Pengguna memasukkan titik asal dan tujuan, yang kemudian diproses melalui public API sehingga jarak tempuh dihitung otomatis, bukan diinput manual. Jarak tersebut dikalikan dengan faktor emisi sesuai moda transportasi yang dipilih untuk menghasilkan estimasi emisi CO2 per perjalanan. Seluruh riwayat perjalanan disimpan di server dan ditampilkan sebagai daftar data perjalanan, sedangkan visualisasinya ada di modul *Personal Sustainability Dashboard*.
3. **Sustainable Habit & Goal Tracker**  
*Dikerjakan oleh Tania Ju*  
Tab **Habit** · `lib/features/habits/`  
Modul ini membantu pengguna membangun kebiasaan berkelanjutan sekaligus mencapai target spesifik, menjadi dua bagian yang saling melengkapi. Pada bagian Habit, pengguna mencatat kebiasaan harian yang bersifat recurring seperti membawa tumbler, menggunakan transportasi umum, atau memilah sampah. Pada bagian Goal, pengguna dapat membuat target dengan deadline tertentu (misalnya "naik transportasi umum 20 kali dalam sebulan") beserta checklist dan progress bar untuk memantau penyelesaiannya. Setiap kali sebuah goal selesai atau sebuah habit mencapai milestone streak tertentu, pencapaian tersebut direkap oleh *Personal Sustainability Dashboard* dan dievaluasi sebagai bagian dari pencapaian keseluruhan pengguna.
4. **Sustainability Community**  
*Dikerjakan oleh Isybal Sama Eleazar Malau*  
Tab **Komunitas** · `lib/features/community/`  
Modul ini menyediakan forum sosial tempat pengguna berbagi tips dan pengalaman seputar gaya hidup berkelanjutan. Pengguna dapat membuat, mengedit, dan menghapus *thread* miliknya sendiri, memberikan reply pada *thread* orang lain, serta memberi like/unlike. Setiap *thread* dapat diberi tag/kategori (misalnya tips, achievement, atau general) untuk memudahkan navigasi. Nama dan avatar penulis pada setiap thread/reply diambil dari modul *Login* berdasarkan *user_id*. Modul ini juga menampilkan post otomatis saat pengguna meraih achievement baru, dengan data pencapaian yang berasal dari modul *Personal Sustainability Dashboard*.
5. **Personal Sustainability Dashboard**  
*Dikerjakan oleh Fildza Hasnalia Nabila*  
Tab **Dashboard** · `lib/features/dashboard/`  
Modul ini berfungsi sebagai halaman rekap terpusat yang mengagregasi data dari seluruh modul lain: total emisi dari *Carbon Footprint Tracker*, kebiasaan dan progress goal dari *Sustainable Habit & Goal Tracker*, serta aktivitas dari *Sustainability Community*. Modul ini menjadi pemilik utama logika penentuan achievement/badge dan menyediakan data pencapaian baru untuk ditampilkan di modul Community. Ringkasan aktivitas ditampilkan dalam bentuk visualisasi yang lebih mudah dibaca user.

## 💻 Peran Pengguna

- **Pengunjung (belum login):** hanya dapat membuka halaman login dan registrasi.
- **User (sudah login):** mengelola profil, mencatat perjalanan dan melihat estimasi emisi, mengelola habit dan goal, memantau dashboard dan badge, serta membuat thread, membalas, dan memberi like di komunitas. Setiap pengguna hanya dapat melihat dan mengubah data miliknya sendiri (kecuali feed komunitas yang terbuka untuk semua user).

## 🔄 Alur Integrasi Data dengan Situs Web

Aplikasi tidak menyimpan data sendiri. Semua data dibaca dari dan dikirim ke situs web Django di PWS melalui web service Django REST Framework.

1. **Login.** Aplikasi mengirim username dan password ke `POST /api/v1/auth/login/`. Django memeriksa akun dan membalas JSON berisi token.
2. **Menyimpan token.** Token disimpan di perangkat (`lib/core/session.dart`), sehingga pengguna tetap login saat aplikasi dibuka kembali.
3. **Request.** Setiap halaman memanggil web service secara asinkron lewat `ApiClient` (`lib/core/api_client.dart`), yang menambahkan header `Authorization: Token <token>`.
4. **Di sisi Django.** View DRF mengenali pengguna dari token, mengambil atau mengubah data di database yang sama dengan situs web (memakai model dan logika yang sama), lalu serializer mengubahnya menjadi JSON.
5. **Menampilkan.** Aplikasi mengubah JSON menjadi objek model Dart (`fromJson`) dan menampilkannya dengan widget.
6. **Hasilnya.** Data yang dibuat di aplikasi langsung terlihat di situs web, dan sebaliknya.

```text
- Flutter (widget) → ApiClient → HTTPS + token → Django REST Framework (view + serializer) → database PWS

- Flutter (widget) ← model Dart ← JSON
```

## 🔗 Tautan

- **Desain Figma:** https://www.figma.com/design/xMVSWGoAmsCNbc0IrEX4gX/PBP-LETSGOOO?node-id=1-2&t=x38m96qwHWQtBWqr-1 *(halaman desain mobile menyusul)*
- **Situs web (PWS):** https://tania-ju-mossly.pws.cs.ui.ac.id/
- **Repositori web:** https://github.com/pbp-kelompok-a5/mossly
- **APK:** *menyusul*

## 🗂️ Struktur Proyek

```text
lib/
├── main.dart              # Titik masuk
├── app.dart               # MaterialApp, tema, provider
├── core/                  
│   ├── config.dart        # Alamat server
│   ├── session.dart       # Token login
│   ├── api_client.dart    # Pemanggilan web service
│   ├── theme.dart         # Warna dan jarak, selaras dengan situs web
│   └── widgets/           # Widget bersama
├── shell/home_shell.dart  # Bottom navigation lima tab
└── features/<modul>/      # Satu folder per modul
    ├── models/            # Kelas data + fromJson
    ├── services/          # Pemanggilan endpoint modul
    ├── pages/             # Halaman
    └── widgets/           # Widget khusus modul
```