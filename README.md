# 📱 NusaInfo - Aplikasi Pengumuman Kampus (Flutter HTTP API)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![HTTP API](https://img.shields.io/badge/REST_API-JSONPlaceholder-green?style=for-the-badge)](https://jsonplaceholder.typicode.com)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20Windows-blue?style=for-the-badge)]()

**NusaInfo** adalah aplikasi mobile berbasis Flutter yang dirancang sebagai portal informasi dan pengumuman interaktif kampus. Aplikasi ini mengimplementasikan integrasi RESTful API menggunakan package `http` dengan menerapkan praktik terbaik (*clean architecture*, pemisahan *service layer*, *error handling*, serta validasi formulir).

---

## 👤 Informasi Pengembang

- **Nama**: Amal Hidayah
- **Email**: amal.hidayah_ti24@nusaputra.ac.id
- **Program Studi**: Teknik Informatika
- **Institusi**: Universitas Nusa Putra
- **Topik / Tugas**: Pemrograman Mobile - HTTP Networking & REST API Integration

---

## 🎯 Fitur & Kemampuan Aplikasi

1. **Daftar Pengumuman (Home Screen)**
   - Mengambil data daftar pengumuman secara asinkron dari REST API (`GET /posts`).
   - Menampilkan nomor ID pengumuman, judul, dan ringkasan isi dalam bentuk kartu (*Card*) yang rapi.
   - Dilengkapi fitur **Pull-to-Refresh** (`RefreshIndicator`) dan tombol muat ulang pada AppBar.
   - Penanganan 3 state utama UI:
     - ⏳ **Loading State**: Menampilkan indikator loading animasi saat data sedang diambil.
     - ⚠️ **Error State**: Menampilkan pesan kesalahan ramah pengguna dan tombol **Coba Lagi (Retry)** ketika koneksi terputus atau server bermasalah.
     - 📋 **Data State**: Merender daftar pengumuman secara dinamis menggunakan `ListView.builder`.

2. **Detail Pengumuman & Komentar (Detail Screen)**
   - Menampilkan isi lengkap pengumuman yang dipilih.
   - Mengambil dan merender daftar tanggapan/komentar yang terhubung ke pengumuman tersebut secara terpisah (`GET /posts/{id}/comments`).
   - Dilengkapi identitas komentator (avatar inisial, nama, email, dan komentar).

3. **Publikasi Pengumuman Baru (Add Post Screen)**
   - Formulir input pengumuman dengan kolom **Judul** dan **Isi Pengumuman**.
   - Validasi data input menggunakan `GlobalKey<FormState>` dan validator `TextFormField` (mencegah pengiriman data kosong).
   - Pengiriman data ke server menggunakan metode `POST /posts` dengan serialisasi JSON (`jsonEncode`).
   - Efek pemuatan interaktif pada tombol simpan saat proses request berlangsung.

4. **Feedback & Notifikasi Interaktif**
   - Menampilkan **Floating SnackBar** bernuansa hijau dengan ikon centang ketika pengumuman berhasil dibuat.
   - Otomatis memperbarui daftar pengumuman di layar utama setelah pengumuman baru berhasil diterbitkan.

5. **Ketahanan Jaringan & Error Handling Komprehensif**
   - Menangkap `SocketException` untuk mendeteksi kondisi perangkat saat offline / tidak ada koneksi internet.
   - Menangkap `http.ClientException` dan memeriksa HTTP status code (200 OK, 201 Created).

---

## 🌐 Dokumentasi REST API

Aplikasi ini menggunakan public REST API dari **JSONPlaceholder**:
- **Base URL**: `https://jsonplaceholder.typicode.com`

| No | Endpoint | HTTP Method | Header | Deskripsi & Kegunaan | Kode Respons Sukses |
|---|---|:---:|---|---|:---:|
| 1 | `/posts` | `GET` | - | Mengambil daftar seluruh pengumuman (*posts*) | `200 OK` |
| 2 | `/posts/{id}/comments` | `GET` | - | Mengambil daftar komentar untuk pengumuman spesifik | `200 OK` |
| 3 | `/posts` | `POST` | `Content-Type: application/json; charset=UTF-8` | Menerbitkan data pengumuman baru | `201 Created` |

---

## 🏗️ Struktur Proyek

Proyek ini menerapkan pemisahan tanggung jawab (*separation of concerns*) yang terstruktur:

```text
nusa_info/
├── lib/
│   ├── main.dart                  # Titik masuk utama aplikasi & konfigurasi tema Material 3
│   ├── models/                    # Data Model dengan serialisasi JSON
│   │   ├── post.dart              # Model Post (id, userId, title, body)
│   │   └── comment.dart           # Model Comment (id, postId, name, email, body)
│   ├── services/                  # Business logic & layer komunikasi HTTP API
│   │   └── post_service.dart      # Service HTTP (GET posts, GET comments, POST post)
│   └── screens/                   # Tampilan antarmuka pengguna (UI/Screens)
│       ├── home_screen.dart       # Layar utama: daftar pengumuman, refresh, & state handler
│       ├── detail_screen.dart     # Layar detail pengumuman & daftar komentar
│       └── add_post_screen.dart   # Layar form penambahan pengumuman & validasi
├── screenshots/                   # Dokumentasi tangkapan layar antarmuka
│   └── 01_home_screen.png
├── test/                          # Unit testing & widget testing
│   ├── widget_test.dart
│   └── generate_screenshots_test.dart
├── pubspec.yaml                   # Konfigurasi dependensi proyek (http, flutter_lints)
└── README.md                      # Dokumentasi komprehensif proyek
```

---

## 💡 Implementasi Kunci Sesuai Standar Pemrograman

### 1. Data Modeling & Serialisasi JSON
Model `Post` dan `Comment` mengimplementasikan factory method `fromJson` untuk konversi dari JSON API ke objek Dart, serta method `toJson` untuk konversi objek Dart ke JSON:

```dart
class Post {
  final int? id;
  final int userId;
  final String title;
  final String body;

  Post({this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      userId: json['userId'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
```

### 2. Service Layer HTTP (`PostService`)
Semua pemanggilan jaringan diisolasi ke dalam `PostService` sehingga tampilan UI tetap bersih dan modular:

```dart
Future<Post> createPost(Post post) async {
  final url = Uri.parse('$_baseUrl/posts');
  final response = await _client.post(
    url,
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(post.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return Post.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal membuat pengumuman baru: ${response.statusCode}');
  }
}
```

### 3. Asynchronous Execution & Future Caching
Untuk mencegah pemanggilan API berulang kali pada setiap *build cycle*, inisialisasi `Future` diletakkan di dalam `initState()`:

```dart
@override
void initState() {
  super.initState();
  _loadPosts(); // Disimpan dalam variabel _postsFuture
}

void _loadPosts() {
  _postsFuture = _postService.getPosts();
}
```

### 4. Validasi Form & SnackBar Feedback
Formulir input menggunakan `Form` dan `GlobalKey<FormState>`. Ketika pengumuman berhasil ditambahkan, pengguna diarahkan kembali ke layar utama dan disambut dengan notifikasi sukses:

```dart
if (_formKey.currentState!.validate()) {
  final newPost = Post(userId: 1, title: _titleController.text, body: _bodyController.text);
  final result = await _postService.createPost(newPost);
  Navigator.pop(context, result);
}
```

---

## 🚀 Panduan Menjalankan Aplikasi

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.13 atau yang lebih baru)
- [Dart SDK](https://dart.dev/get-dart)
- Web Browser (Google Chrome / Microsoft Edge) atau Android Emulator / Perangkat Fisik

### Langkah Instalasi
1. **Clone repository ini**:
   ```bash
   git clone https://github.com/amal-hidayah/nusa_info.git
   cd nusa_info
   ```

2. **Unduh dependensi proyek**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   - **Di Browser (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **Di Port Tertentu (misal: 8080)**:
     ```bash
     flutter run -d chrome --web-port=8080
     ```
   - **Di Perangkat Android**:
     ```bash
     flutter run -d android
     ```
   - **Di Desktop Windows**:
     ```bash
     flutter run -d windows
     ```

---

## 📦 Dependensi Utama

| Package | Versi | Fungsi |
|---|---|---|
| [`flutter`](https://flutter.dev) | SDK | Framework UI multi-platform |
| [`http`](https://pub.dev/packages/http) | `^1.6.0` | Pustaka untuk melakukan HTTP request (GET, POST, dll.) |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | `^1.0.8` | Kumpulan ikon bergaya iOS |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) | `^6.0.0` | Standar aturan analisis kode untuk Dart & Flutter |

---

## 📄 Lisensi & Hak Cipta

Proyek ini dibuat dan dikembangkan untuk keperluan akademik dan pembelajaran pada mata kuliah Pemrograman Mobile di **Universitas Nusa Putra**.
Seluruh kode dapat digunakan dan dikembangkan untuk tujuan edukasi.
