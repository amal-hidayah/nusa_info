class Post {
  final int? id;
  final int userId;
  final String title;
  final String body;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  // Mengubah JSON dari API menjadi objek Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      userId: json['userId'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  // Mengubah objek Post menjadi Map/JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
