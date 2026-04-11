class Event {
  final String id;
  final String title;
  final String clubName;
  final DateTime date;
  final String time;
  final AttendanceStatus status;

  Event({
    required this.id,
    required this.title,
    required this.clubName,
    required this.date,
    required this.time,
    required this.status,
  });
}

enum AttendanceStatus { attending, notAttending, maybe }