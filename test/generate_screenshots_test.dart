import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nusa_info/models/post.dart';
import 'package:nusa_info/models/comment.dart';

Future<void> saveScreenshot({
  required WidgetTester tester,
  required GlobalKey boundaryKey,
  required String outputPath,
}) async {
  final RenderRepaintBoundary boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(pngBytes);
  // ignore: avoid_print
  print('Saved $outputPath (${pngBytes.length} bytes)');
}

void main() {
  testWidgets('Generate all screenshots', (tester) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2.0;

    final boundaryKey = GlobalKey();

    Widget wrap(Widget screen) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: screen,
        ),
      );
    }

    // 1. Home Screen
    final samplePosts = [
      Post(
        id: 1,
        userId: 1,
        title: 'Pengumuman Libur Nasional Semester Ganjil',
        body:
            'Diberitahukan kepada seluruh civitas akademika bahwa perkuliahan diliburkan mulai tanggal 10 hingga 15 November sesuai kalender akademik.',
      ),
      Post(
        id: 2,
        userId: 1,
        title: 'Pendaftaran Beasiswa Unggulan Prestasi 2026',
        body:
            'Pendaftaran beasiswa prestasi dibuka untuk mahasiswa semester 3 sampai 7 dengan IPK minimal 3.50. Segera lengkapi berkas di portal.',
      ),
      Post(
        id: 3,
        userId: 2,
        title: 'Jadwal Pemeliharaan Server Portal Akademik',
        body:
            'Akan dilakukan pemeliharaan rutin pada server utama pada Sabtu pukul 22.00 WIB. Layanan SIAKAD tidak dapat diakses sementara.',
      ),
      Post(
        id: 4,
        userId: 3,
        title: 'Workshop Flutter & Mobile Cloud Architecture',
        body:
            'Ikuti pelatihan komprehensif mobile development menggunakan Flutter dan Google Cloud Platform bersama praktisi industri.',
      ),
      Post(
        id: 5,
        userId: 3,
        title: 'Batas Akhir Pengisian Kartu Rencana Studi (KRS)',
        body:
            'Pengisian KRS online untuk semester genap berakhir pada tanggal 20 November pukul 23:59 WIB. Mahasiswa diimbau segera konsultasi.',
      ),
    ];

    await tester.pumpWidget(
      wrap(
        Scaffold(
          appBar: AppBar(
            title: const Text('NusaInfo - Pengumuman'),
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: samplePosts.length,
            itemBuilder: (context, index) {
              final post = samplePosts[index];
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
                      '${post.id}',
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
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pengumuman'),
          ),
        ),
      ),
    );
    await tester.pump();
    await saveScreenshot(
      tester: tester,
      boundaryKey: boundaryKey,
      outputPath: 'screenshots/01_home_screen.png',
    );

    // 2. Detail Screen
    final sampleComments = [
      Comment(
        id: 1,
        postId: 1,
        name: 'Budi Santoso',
        email: 'budi.santoso@nusaputra.ac.id',
        body: 'Terima kasih atas informasinya min, sangat membantu!',
      ),
      Comment(
        id: 2,
        postId: 1,
        name: 'Siti Rahma',
        email: 'siti.rahma@student.ac.id',
        body: 'Apakah perpustakaan tetap buka selama libur tersebut?',
      ),
      Comment(
        id: 3,
        postId: 1,
        name: 'Admin Akademik',
        email: 'layanan@nusaputra.ac.id',
        body: 'Layanan daring perpustakaan dan SIAKAD tetap dapat diakses 24 jam.',
      ),
    ];

    await tester.pumpWidget(
      wrap(
        Scaffold(
          appBar: AppBar(
            title: const Text('Detail Pengumuman'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: const Text(
                                '#1',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Pengumuman Libur Nasional Semester Ganjil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Diberitahukan kepada seluruh civitas akademika bahwa perkuliahan diliburkan mulai tanggal 10 hingga 15 November sesuai kalender akademik.',
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Komentar & Diskusi (3)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...sampleComments.map(
                  (comment) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.indigo.shade50,
                                child: Text(
                                  comment.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  comment.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(comment.body),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await saveScreenshot(
      tester: tester,
      boundaryKey: boundaryKey,
      outputPath: 'screenshots/02_detail_screen.png',
    );

    // 3. Add Post Screen
    await tester.pumpWidget(
      wrap(
        Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Pengumuman Baru'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: 'Pengumuman Ujian Tengah Semester Ganjil',
                          decoration: const InputDecoration(
                            labelText: 'Judul Pengumuman',
                            hintText: 'Masukkan judul pengumuman...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue:
                              'Jadwal dan kartu ujian UTS sudah dapat diunduh melalui portal akademik mulai besok.',
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Isi Pengumuman',
                            hintText: 'Masukkan rincian informasi...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send),
                            label: const Text(
                              'Publikasikan Pengumuman',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await saveScreenshot(
      tester: tester,
      boundaryKey: boundaryKey,
      outputPath: 'screenshots/03_add_post_screen.png',
    );

    // 4. SnackBar Success
    await tester.pumpWidget(
      wrap(
        Scaffold(
          appBar: AppBar(
            title: const Text('NusaInfo - Pengumuman'),
            elevation: 2,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const ListTile(
                  leading: CircleAvatar(child: Text('101')),
                  title: Text(
                    'Pengumuman Ujian Tengah Semester Ganjil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Jadwal dan kartu ujian UTS sudah dapat diunduh melalui portal...',
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const ListTile(
                  leading: CircleAvatar(child: Text('1')),
                  title: Text(
                    'Pengumuman Libur Nasional Semester Ganjil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Diberitahukan kepada seluruh civitas akademika bahwa perkuliahan...',
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pengumuman berhasil dipublikasikan!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Tambah Pengumuman'),
          ),
        ),
      ),
    );
    await tester.pump();
    await saveScreenshot(
      tester: tester,
      boundaryKey: boundaryKey,
      outputPath: 'screenshots/04_snackbar_success.png',
    );

    // 5. Offline Error
    await tester.pumpWidget(
      wrap(
        Scaffold(
          appBar: AppBar(
            title: const Text('NusaInfo - Pengumuman'),
            elevation: 2,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal Memuat Data',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Koneksi internet terputus. Silakan periksa jaringan Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await saveScreenshot(
      tester: tester,
      boundaryKey: boundaryKey,
      outputPath: 'screenshots/05_error_offline.png',
    );

    exit(0);
  });
}
