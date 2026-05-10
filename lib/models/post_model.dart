import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String clubName;
  final String caption;
  final String? imagePath;
  final String? location;
  final String? date;
  final String? audio;
  final String? tagPeople;
  final List<String> likes;
  final String createdBy;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.clubName,
    required this.caption,
    this.imagePath,
    this.location,
    this.date,
    this.audio,
    this.tagPeople,
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
      imagePath: data['imagePath'],
      location: data['location'],
      date: data['date'],
      audio: data['audio'],
      tagPeople: data['tagPeople'],
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
      'imagePath': imagePath,
      'location': location,
      'date': date,
      'audio': audio,
      'tagPeople': tagPeople,
      'likes': likes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}