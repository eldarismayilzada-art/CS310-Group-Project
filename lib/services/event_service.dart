import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  // CREATE
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

  // READ - real-time stream for a user
  Stream<List<EventModel>> getEvents(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  // UPDATE - change attendance status
  Future<void> updateStatus(
      String eventId, AttendanceStatus status) async {
    await _db.collection(_collection).doc(eventId).update({
      'status': status.name,
    });
  }

  // DELETE
  Future<void> deleteEvent(String eventId) async {
    await _db.collection(_collection).doc(eventId).delete();
  }
}