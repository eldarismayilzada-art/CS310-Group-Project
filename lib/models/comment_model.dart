import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    required this.fontSize,
    required this.textColor,
    required this.fontFamily,
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
      fontSize: (data['fontSize'] ?? 16).toDouble(),
      textColor: data['textColor'] ?? Colors.black.value,
      fontFamily: data['fontFamily'] ?? 'Roboto',
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
      'fontSize': fontSize,
      'textColor': textColor,
      'fontFamily': fontFamily,
    };
  }
}
