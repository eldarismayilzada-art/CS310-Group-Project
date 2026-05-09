import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String bio;
  final List<String> interests;
  final String? avatarUrl;
  final String? grade;
  final String? dateOfBirth;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.interests,
    this.avatarUrl,
    this.grade,
    this.dateOfBirth,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      avatarUrl: data['avatarUrl'],
      grade: data['grade'],
      dateOfBirth: data['dateOfBirth'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'interests': interests,
      'avatarUrl': avatarUrl,
      'grade': grade,
      'dateOfBirth': dateOfBirth,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}