import '../../model/comment/comment.dart';

class CommentDto {
  static const String messageKey = 'message';
  static const String createdAtKey = 'createdAt';

  static Comment fromJson(String id, Map<String, dynamic> json) {
    assert(json[messageKey] is String);
    assert(json[createdAtKey] is String);

    return Comment(
      id: id,
      message: json[messageKey],
      createdAt: DateTime.parse(json[createdAtKey]),
    );
  }

  static Map<String, dynamic> toJson(Comment comment) {
    return {
      messageKey: comment.message,
      createdAtKey: comment.createdAt.toIso8601String(),
    };
  }
}
