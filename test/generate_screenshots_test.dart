import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:nusa_info/models/post.dart';
import 'package:nusa_info/models/comment.dart';
import 'package:nusa_info/services/post_service.dart';
import 'package:nusa_info/screens/home_screen.dart';
import 'package:nusa_info/screens/detail_screen.dart';
import 'package:nusa_info/screens/add_post_screen.dart';

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
}

void main() {
  final samplePosts = [
    {
      'id': 1,
      'userId': 1,
      'title': 'Pengumuman Libur Nasional Semester Ganjil',
      'body':
          'Diberitahukan kepada seluruh civitas akademika bahwa perkuliahan diliburkan mulai tanggal 10 hingga 15 November sesuai kalender akademik.',
    },
    {
      'id': 2,
      'userId': 1,
      'title': 'Pendaftaran Beasiswa Unggulan Prestasi 2026',
      'body':
          'Pendaftaran beasiswa prestasi dibuka untuk mahasiswa semester 3 sampai 7 dengan IPK minimal 3.50. Segera lengkapi berkas di portal.',
    },
    {
      'id': 3,
      'userId': 2,
      'title': 'Jadwal Pemeliharaan Server Portal Akademik',
      'body':
          'Akan dilakukan pemeliharaan rutin pada server utama pada Sabtu pukul 22.00 WIB. Layanan SIAKAD tidak dapat diakses sementara.',
    },
    {
      'id': 4,
      'userId': 3,
      'title': 'Workshop Flutter & Mobile Cloud Architecture',
      'body':
          'Ikuti pelatihan komprehensif mobile development menggunakan Flutter dan Google Cloud Platform bersama praktisi industri.',
    },
  ];

  final sampleComments = [
    {
      'id': 1,
      'postId': 1,
      'name': 'Budi Santoso',
      'email': 'budi.santoso@nusaputra.ac.id',
      'body': 'Terima kasih atas informasinya min, sangat membantu!',
    },
    {
      'id': 2,
      'postId': 1,
      'name': 'Siti Rahma',
      'email': 'siti.rahma@student.ac.id',
      'body': 'Apakah perpustakaan tetap buka selama libur tersebut?',
    },
    {
      'id': 3,
      'postId': 1,
      'name': 'Admin Akademik',
      'email': 'layanan@nusaputra.ac.id',
      'body': 'Layanan daring perpustakaan tetap dapat diakses 24 jam.',
    },
  ];

  testWidgets('Generate all required screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    tester.view.devicePixelRatio = 2.0;

    // Mock client untuk kondisi normal (online)
    final normalMockClient = MockClient((request) async {
      if (request.url.path == '/posts' && request.method == 'GET') {
        return http.Response(
          jsonEncode(samplePosts),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path.contains('/comments') && request.method == 'GET') {
        return http.Response(
          jsonEncode(sampleComments),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/posts' && request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        body['id'] = 101;
        return http.Response(
          jsonEncode(body),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });

    // Mock client untuk kondisi error (internet mati)
    final offlineMockClient = MockClient((request) async {
      throw const SocketException('Failed host lookup: jsonplaceholder.typicode.com');
    });

    final normalService = PostService(client: normalMockClient);
    final offlineService = PostService(client: offlineMockClient);

    // 1. Screenshot Home Screen (Normal / Berhasil memuat)
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: key,
            child: HomeScreen(postService: normalService),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(
        tester: tester,
        boundaryKey: key,
        outputPath: 'screenshots/01_home_screen.png',
      );
    }

    // 2. Screenshot Detail Screen
    {
      final key = GlobalKey();
      final post = Post(
        id: 1,
        userId: 1,
        title: 'Pengumuman Libur Nasional Semester Ganjil',
        body:
            'Diberitahukan kepada seluruh civitas akademika bahwa perkuliahan diliburkan mulai tanggal 10 hingga 15 November sesuai kalender akademik.',
      );

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: key,
            child: DetailScreen(
              post: post,
              postService: normalService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(
        tester: tester,
        boundaryKey: key,
        outputPath: 'screenshots/02_detail_screen.png',
      );
    }

    // 3. Screenshot Add Post Screen
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: key,
            child: AddPostScreen(postService: normalService),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Isi form agar terlihat terisi
      await tester.enterText(
        find.byType(TextFormField).first,
        'Pengumuman Ujian Tengah Semester Ganjil',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Jadwal dan kartu ujian UTS sudah dapat diunduh melalui portal akademik mulai besok.',
      );
      await tester.pump();

      await saveScreenshot(
        tester: tester,
        boundaryKey: key,
        outputPath: 'screenshots/03_add_post_screen.png',
      );
    }

    // 4. Screenshot SnackBar Berhasil Dibuat pada Home Screen
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: key,
            child: Builder(
              builder: (context) {
                return Scaffold(
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
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Pengumuman'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tampilkan SnackBar sukses
      final scaffoldContext = tester.element(find.byType(Scaffold));
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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
          duration: Duration(seconds: 10),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await saveScreenshot(
        tester: tester,
        boundaryKey: key,
        outputPath: 'screenshots/04_snackbar_success.png',
      );
    }

    // 5. Screenshot Pesan Error saat Internet Mati
    {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: key,
            child: HomeScreen(postService: offlineService),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await saveScreenshot(
        tester: tester,
        boundaryKey: key,
        outputPath: 'screenshots/05_error_offline.png',
      );
    }
  });
}
