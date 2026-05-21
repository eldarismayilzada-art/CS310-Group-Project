import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  Future<void> createEvent(EventModel event) async {
    try {
      final ref = _db.collection(_collection).doc();


      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.date.hour,
        event.date.minute,
      );

      await ref.set({
        'id': ref.id, 
        'title': event.title,
        'clubName': event.clubName,
        'date': Timestamp.fromDate(eventDate),
        'time': event.time,
        'status': event.status.name,
        'createdBy': event.createdBy,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print("Etkinlik Oluşturma Hatası: $e");
      rethrow;
    }
  }


  Stream<List<EventModel>> getEvents(String userId) {
    return _db
        .collection(_collection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList())
        .handleError((error) {
          print("Takvim Etkinlikleri Getirme Hatası: $error");
        });
  }


  Stream<List<EventModel>> getTodaysEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList())
        .handleError((error) {
          print("Bugünün Etkinlikleri (Hikaye) Hatası: $error");
        });
  }

  Future<void> updateStatus(String eventId, AttendanceStatus status) async {
    try {
      await _db.collection(_collection).doc(eventId).update({
        'status': status.name,
      });
    } catch (e) {
      print("Durum Güncelleme Hatası: $e");
      rethrow;
    }
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
