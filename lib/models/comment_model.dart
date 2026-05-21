import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String text;
  final String authorName;
  final String createdBy;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.authorName,
    required this.createdBy,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      text: data['text'] ?? '',
      authorName: data['authorName'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'postId': postId,
      'text': text,
      'authorName': authorName,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}