import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; 
  final String email;
  final String username;
  final String role; 
  final List<String> interests;
  final String bio;
  final String? avatarUrl;
  final bool onboardingComplete;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.interests,
    required this.bio,
    this.avatarUrl,
    required this.onboardingComplete,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id, 
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? 'student',
      interests: List<String>.from(data['interests'] ?? []),
      bio: data['bio'] ?? '',
      avatarUrl: data['avatarUrl'],
      onboardingComplete: data['onboardingComplete'] ?? data['isFirstLogin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'interests': interests,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'onboardingComplete': onboardingComplete,
    };
  }
}
