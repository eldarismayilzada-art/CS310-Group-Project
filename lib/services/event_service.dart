import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  Future<void> createEvent(EventModel event) async {
    final ref = _db.collection(_collection).doc();
    await ref.set({
      'title': event.title,
      'clubName': event.clubName,
      'date': Timestamp.fromDate(event.date),
      'time': event.time,
      'status': event.status.name,
      'createdBy': event.createdBy,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // READ — no orderBy so no composite index needed; we sort in Dart
  Stream<List<EventModel>> getEvents(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => a.date.compareTo(b.date));
          return list;
        });
  }

  // ADDED: Fetch events scheduled for today
  Stream<List<EventModel>> getTodaysEvents() {
    final now = DateTime.now();
    // Start of today: 00:00:00
    final startOfDay = DateTime(now.year, now.month, now.day);
    // End of today: 23:59:59
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _db
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
          // Sort them by time/date just like your other method
          list.sort((a, b) => a.date.compareTo(b.date));
          return list;
        });
  }

  // UPDATE attendance status
  Future<void> updateStatus(String eventId, AttendanceStatus status) async {
    await _db.collection(_collection).doc(eventId).update({
      'status': status.name,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection(_collection).doc(eventId).delete();
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
}