import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'detail_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  final PostService? postService;

  const HomeScreen({super.key, this.postService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostService _postService;

  // Variabel untuk menampung Future
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postService = widget.postService ?? PostService();
    // 6. Panggil Future di initState(), bukan di dalam build()
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = _postService.getPosts();
  }

  // 7. Fungsi untuk RefreshIndicator
  Future<void> _handleRefresh() async {
    setState(() {
      _loadPosts();
    });
    // Menunggu hingga future selesai agar indikator loading refresh berhenti
    try {
      await _postsFuture;
    } catch (_) {
      // Error ditangani oleh FutureBuilder
    }
  }

  // 8. Navigasi ke Add Post Screen dan menampilkan SnackBar setelah berhasil
  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(postService: _postService),
      ),
    );

    // Jika pengumuman berhasil dibuat, tampilkan SnackBar
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Pengumuman berhasil dipublikasikan!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      // Muat ulang daftar pengumuman
      setState(() {
        _loadPosts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaInfo - Pengumuman'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: () {
              setState(() {
                _loadPosts();
              });
            },
          ),
        ],
      ),
      // 7. RefreshIndicator pada Home Screen untuk memuat ulang data
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // State: Menunggu data (Loading)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data pengumuman...'),
                  ],
                ),
              );
            }

            // State: Terjadi error
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal Memuat Data',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _loadPosts();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // State: Data kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('Tidak ada pengumuman tersedia.'),
                    ),
                  ),
                ],
              );
            }

            // State: Data berhasil dimuat
            final posts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        '${post.id ?? (index + 1)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            post: post,
                            postService: _postService,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPost,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pengumuman'),
      ),
    );
  }
}
