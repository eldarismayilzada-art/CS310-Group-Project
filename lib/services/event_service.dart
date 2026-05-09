import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  // --- CREATE ---
  Future<void> createEvent(EventModel event) async {
    final ref = _db.collection(_collection).doc();
    final newEvent = EventModel(
      id: ref.id,
      title: event.title,
      clubName: event.clubName,
      date: event.date,
      time: event.time,
      status: event.status,
      createdBy: event.createdBy,
      createdAt: DateTime.now(),
    );
    await ref.set(newEvent.toFirestore());
  }

  Stream<List<EventModel>> getAllEvents() {
    return _db
        .collection(_collection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Stream<List<EventModel>> getTodaysEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Stream<List<EventModel>> getEventsByClub(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<void> updateStatus(String eventId, AttendanceStatus status) async {
    await _db.collection(_collection).doc(eventId).update({
      'status': status.name,
    });
  }

  // --- DELETE ---
  Future<void> deleteEvent(String eventId) async {
    await _db.collection(_collection).doc(eventId).delete();
  }
}
