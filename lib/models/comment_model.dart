import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId; 
  final String text;
  final String authorName;
  final String createdBy;
  final DateTime createdAt;
  final double fontSize;
  final int textColor;
  final String fontFamily;

  CommentModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.authorName,
    required this.createdBy,
    required this.createdAt,
    this.fontSize = 14.0,       
    this.textColor = 0xFF000000, 
    this.fontFamily = 'Poppins',  
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      text: data['text'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fontSize: (data['fontSize'] as num?)?.toDouble() ?? 14.0,
      textColor: data['textColor'] as int? ?? 0xFF000000,
      fontFamily: data['fontFamily'] ?? 'Poppins',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'text': text,
      'authorName': authorName,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'fontSize': fontSize,
      'textColor': textColor,
      'fontFamily': fontFamily,
    };
  }
}
