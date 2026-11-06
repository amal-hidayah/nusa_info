import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  PostService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil daftar seluruh pengumuman (posts)
  Future<List<Post>> getPosts() async {
    try {
      // 1. Buat alamat URL
      final url = Uri.parse('$_baseUrl/posts');

      // 2. Kirim request HTTP GET
      final response = await _client.get(url);

      // 3. Cek status code
      if (response.statusCode == 200) {
        // 4. Ubah JSON menjadi objek Post
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat pengumuman. Kode status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Koneksi internet terputus. Silakan periksa jaringan Anda.');
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError') ||
          e.toString().contains('ClientException')) {
        throw Exception('Koneksi internet terputus. Silakan periksa jaringan Anda.');
      }
      rethrow;
    }
  }

  /// Mengambil daftar komentar untuk pengumuman tertentu
  Future<List<Comment>> getComments(int postId) async {
    try {
      // 1. Buat alamat URL
      final url = Uri.parse('$_baseUrl/posts/$postId/comments');

      // 2. Kirim request HTTP GET
      final response = await _client.get(url);

      // 3. Cek status code
      if (response.statusCode == 200) {
        // 4. Ubah JSON menjadi objek Comment
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => Comment.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat komentar. Kode status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Koneksi internet terputus. Silakan periksa jaringan Anda.');
    } on http.ClientException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError') ||
          e.toString().contains('ClientException')) {
        throw Exception('Koneksi internet terputus. Silakan periksa jaringan Anda.');
      }
      rethrow;
    }
  }

  /// Membuat pengumuman baru (POST /posts)
  Future<Post> createPost(Post post) async {
    try {
      // 1. Buat alamat URL
      final url = Uri.parse('$_baseUrl/posts');

      // 2. Kirim request HTTP POST dengan jsonEncode()
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(post.toJson()),
      );

      // 3. Cek status code (201 Created atau 200 OK)
      if (response.statusCode == 201 || response.statusCode == 200) {
        // 4. Ubah JSON menjadi objek Post
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Post.fromJson(data);
      } else {
        throw Exception(
          'Gagal membuat pengumuman baru. Kode status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Gagal mengirim data. Koneksi internet terputus.');
    } on http.ClientException {
      throw Exception('Gagal mengirim data. Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError') ||
          e.toString().contains('ClientException')) {
        throw Exception('Gagal mengirim data. Koneksi internet terputus.');
      }
      rethrow;
    }
  }
}
