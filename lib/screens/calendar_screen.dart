import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'day_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  final List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final uid = context.read<AuthProvider>().firebaseUser?.uid;
        if (uid != null) {
          context.read<EventProvider>().listenToEvents(uid);
        }
      });
    }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return AppColors.attended;
      case AttendanceStatus.notAttending: return AppColors.notAttended;
      case AttendanceStatus.maybe:        return AppColors.maybe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendar',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
              style: const TextStyle(fontFamily: 'Poppins',
                color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/add-event'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendarCard(eventProvider),
                const SizedBox(height: 16),
                _buildLegend(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarCard(EventProvider eventProvider) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekdayLabels(),
          _buildCalendarGrid(eventProvider),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary,
            onPressed: () => setState(() =>
              _focusedMonth = DateTime(
                _focusedMonth.year, _focusedMonth.month - 1)),
          ),
          Text(
            '${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
              fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary,
            onPressed: () => setState(() =>
              _focusedMonth = DateTime(
                _focusedMonth.year, _focusedMonth.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: days.map((d) => Expanded(
          child: Center(
            child: Text(d, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 11,
              fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(EventProvider eventProvider) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.1,
        ),
        itemCount: totalCells,
        itemBuilder: (ctx, index) {
          final dayNumber = index - startOffset + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return const SizedBox();
          }

          final thisDay = DateTime(
            _focusedMonth.year, _focusedMonth.month, dayNumber);
          final events = eventProvider.eventsForDay(thisDay);
          final isToday = today.day == dayNumber &&
            today.month == _focusedMonth.month &&
            today.year == _focusedMonth.year;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayDetailScreen(
                    day: thisDay,
                    events: events,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isToday
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$dayNumber', style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday
                      ? AppColors.primary
                      : const Color(0xFF1A1A2E),
                  )),
                  if (events.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(3).map((e) => Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.only(right: 1, top: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(e.status),
                          shape: BoxShape.circle,
                        ),
                      )).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendItem(AppColors.attended, 'Going'),
            _legendItem(AppColors.maybe, 'Maybe'),
            _legendItem(AppColors.notAttended, 'Not going'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11,
          color: Color(0xFF6B6B6B))),
      ],
    );
  }
}