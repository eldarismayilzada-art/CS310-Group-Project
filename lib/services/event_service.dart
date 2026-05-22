import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  // CREATE
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

  // UPDATE attendance status
  Future<void> updateStatus(String eventId, AttendanceStatus status) async {
    await _db.collection(_collection).doc(eventId).update({
      'status': status.name,
    });
  }

  // DELETE
  Future<void> deleteEvent(String eventId) async {
    await _db.collection(_collection).doc(eventId).delete();
  }
}