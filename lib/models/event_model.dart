import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String clubName;
  final DateTime date;
  final String time;
  final AttendanceStatus status;
  final String createdBy;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.clubName,
    required this.date,
    required this.time,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      clubName: data['clubName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AttendanceStatus.maybe,
      ),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'clubName': clubName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum AttendanceStatus { attending, notAttending, maybe }