import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime day;
  final List<Event> events;

  const DayDetailScreen({
    super.key,
    required this.day,
    required this.events,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late List<Event> _events;

  final List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.events);
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return AppColors.attended;
      case AttendanceStatus.notAttending: return AppColors.notAttended;
      case AttendanceStatus.maybe:        return AppColors.maybe;
    }
  }

  String _statusLabel(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return 'Going';
      case AttendanceStatus.notAttending: return 'Not going';
      case AttendanceStatus.maybe:        return 'Maybe';
    }
  }

  IconData _statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return Icons.check_circle_rounded;
      case AttendanceStatus.notAttending: return Icons.cancel_rounded;
      case AttendanceStatus.maybe:        return Icons.help_rounded;
    }
  }

  void _removeEvent(String id) {
    setState(() => _events.removeWhere((e) => e.id == id));
  }

  Future<void> _goToAddEvent() async {
    await Navigator.pushNamed(context, '/add-event');
    // When we come back, in a real app you'd refresh events here
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel =
      '${_monthNames[widget.day.month]} ${widget.day.day}, ${widget.day.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayLabel,
              style: const TextStyle(
                fontFamily: 'Poppins', color: Colors.white,
                fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              _events.isEmpty
                ? 'No events'
                : '${_events.length} event${_events.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Poppins', color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _goToAddEvent,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Add',
                style: TextStyle(
                  fontFamily: 'Poppins', color: Colors.white,
                  fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: _events.isEmpty ? _buildEmpty() : _buildEventList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, size: 72,
            color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No events this day',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
              fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('Tap Add to create one',
            style: TextStyle(fontFamily: 'Poppins',
              fontSize: 13, color: Colors.grey[400])),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _goToAddEvent,
            icon: const Icon(Icons.add),
            label: const Text('Add event',
              style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      itemCount: _events.length,
      itemBuilder: (ctx, i) => _buildEventCard(_events[i]),
    );
  }

  Widget _buildEventCard(Event event) {
    final color = _statusColor(event.status);

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.notAttended.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded,
          color: AppColors.notAttended, size: 26),
      ),
      onDismissed: (_) => _removeEvent(event.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Status icon circle
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon(event.status),
                  color: color, size: 22),
              ),
              const SizedBox(width: 12),
              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.group_rounded,
                        size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(event.clubName,
                        style: AppTextStyles.muted),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded,
                        size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(event.time,
                        style: AppTextStyles.muted),
                    ]),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(event.status),
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}