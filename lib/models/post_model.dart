import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String clubName;
  final String caption;
  final String? imageUrl;
  final String? location;
  final List<String> likes;
  final String createdBy;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.clubName,
    required this.caption,
    this.imageUrl,
    this.location,
    required this.likes,
    required this.createdBy,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      clubName: data['clubName'] ?? '',
      caption: data['caption'] ?? '',
      imageUrl: data['imageUrl'],
      location: data['location'],
      likes: List<String>.from(data['likes'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'clubName': clubName,
      'caption': caption,
      'imageUrl': imageUrl,
      'location': location,
      'likes': likes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}