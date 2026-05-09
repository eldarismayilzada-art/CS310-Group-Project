import 'package:cloud_firestore/cloud_firestore.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<Map<String, String>> sabanciClubs = [
    {'name': 'Sabanci Intelligent System and Innovation (SUIS)', 'category': 'Science and Technology'},
    {'name': 'Artelier Fine Arts Club', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Astronomy Society (ASTROSU)', 'category': 'Science and Technology'},
    {'name': 'Beautiful and Effective Speaking Club (SUPEAK)', 'category': 'Hobby'},
    {'name': 'Blockchain Club', 'category': 'Science and Technology'},
    {'name': 'Bridge Club', 'category': 'Hobby'},
    {'name': 'Cinema Club (SİNEK)', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Comedy Club', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Computer Science Society (CSS)', 'category': 'Science and Technology'},
    {'name': 'Dance Club (SUDANCE)', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Debate Club', 'category': 'Career'},
    {'name': 'Deep Tech Club (DTC)', 'category': 'Science and Technology'},
    {'name': 'E-Sports Club', 'category': 'Hobby'},
    {'name': 'Economics and Management Club', 'category': 'Career'},
    {'name': 'Energy Club (EC)', 'category': 'Science and Technology'},
    {'name': 'Fashion Club (SUMODA)', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Game Development Club', 'category': 'Science and Technology'},
    {'name': 'Health and Wellness Club (SUWELL)', 'category': 'Hobby'},
    {'name': 'IEEE Student Branch', 'category': 'Science and Technology'},
    {'name': 'kAi - AI and Machine Learning Club', 'category': 'Science and Technology'},
    {'name': 'Model United Nations (SUMUN)', 'category': 'Career'},
    {'name': 'Motor Racing Club', 'category': 'Sportif'},
    {'name': 'Motorsport and Technologies Club', 'category': 'Science and Technology'},
    {'name': 'Music Club', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Photography Club (FOCUS)', 'category': 'Hobby'},
    {'name': 'Robotics Club (SURK)', 'category': 'Science and Technology'},
    {'name': 'Sabanci University Rocket Club (SUROC)', 'category': 'Science and Technology'},
    {'name': 'Sabanci University Rover Club (SuRover)', 'category': 'Science and Technology'},
    {'name': 'Sabanci University Running Club (KoSU)', 'category': 'Sportif'},
    {'name': 'Sailing and Maritime Club (Susail)', 'category': 'Sportif'},
    {'name': 'Search and Rescue Club (SUAK)', 'category': 'Sportif'},
    {'name': 'Ski Club (SUSNOW)', 'category': 'Sportif'},
    {'name': 'Sports Club (SK)', 'category': 'Sportif'},
    {'name': 'Sustainability Club (SÜR)', 'category': 'Science and Technology'},
    {'name': 'SuTrong - Strength Training Club', 'category': 'Sportif'},
    {'name': 'Theatre Club (SUO)', 'category': 'Art - Performance & Entertainment'},
    {'name': 'Underwater Sports and Research Club (SUSS)', 'category': 'Sportif'},
    {'name': 'Vegan Club (VEGANSA)', 'category': 'Hobby'},
    {'name': 'Young Entrepreneurs Club', 'category': 'Career'},
  ];

  // Seed clubs into Firestore (call once)
  Future<void> seedClubs() async {
    final existing = await _db.collection('clubs').limit(1).get();
    if (existing.docs.isNotEmpty) return; // already seeded

    final batch = _db.batch();
    for (final club in sabanciClubs) {
      final ref = _db.collection('clubs').doc();
      batch.set(ref, {
        'id': ref.id,
        'name': club['name'],
        'category': club['category'],
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  // Get all clubs as stream
  Stream<List<Map<String, dynamic>>> getClubs() {
    return _db
        .collection('clubs')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
}