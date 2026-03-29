class Comment {
  final String id;
  final String message;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'Comment(id: $id, message: $message, createdAt: $createdAt)';
  }
}
