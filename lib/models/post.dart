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

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] is int
        ? json['id']
        : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
    userId: json['userId'] is int
        ? json['userId']
        : int.parse(json['userId'].toString()),
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'userId': userId,
    'title': title,
    'body': body,
  };

  @override
  String toString() =>
      'Post(id: $id, userId: $userId, title: $title, body: ${body.length} chars)';
}
