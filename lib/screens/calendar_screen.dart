import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().firebaseUser?.uid;
      if (uid != null) context.read<EventProvider>().listenToEvents(uid);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return AppColors.attended;
      case AttendanceStatus.notAttending: return AppColors.notAttended;
      case AttendanceStatus.maybe:        return AppColors.maybe;
    }
  }

  String _statusLabel(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return 'Coming ✓';
      case AttendanceStatus.notAttending: return 'Not going';
      case AttendanceStatus.maybe:        return 'Maybe?';
    }
  }

  IconData _statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.attending:    return Icons.check_circle_rounded;
      case AttendanceStatus.notAttending: return Icons.cancel_rounded;
      case AttendanceStatus.maybe:        return Icons.help_rounded;
    }
  }

  String _weekdayFull(int w) {
    const d = ['', 'Monday', 'Tuesday', 'Wednesday',
                'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return d[w];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Calendar',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add-event');
              if (mounted) {
                final uid = context.read<AuthProvider>().firebaseUser?.uid;
                if (uid != null)
                  context.read<EventProvider>().listenToEvents(uid);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          final dayEvents = eventProvider.eventsForDay(_selectedDay);

          // Everything in one CustomScrollView so nothing overflows
          return CustomScrollView(
            slivers: [
              // ── CALENDAR CARD ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _buildMonthHeader(),
                      _buildWeekdayRow(),
                      _buildMonthGrid(eventProvider),
                      const SizedBox(height: 10),
                      _buildLegend(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── SELECTED DAY LABEL ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Row(
                    children: [
                      Text(
                        '${_monthNames[_selectedDay.month]} ${_selectedDay.day}'
                        ', ${_selectedDay.year}',
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _weekdayFull(_selectedDay.weekday),
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 13,
                            color: Color(0xFF6B6B6B)),
                      ),
                      const Spacer(),
                      Text(
                        '${dayEvents.length} event${dayEvents.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // ── EVENT LIST or EMPTY STATE ──
              if (dayEvents.isEmpty)
                SliverToBoxAdapter(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildEventCard(dayEvents[i]),
                      childCount: dayEvents.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary,
            onPressed: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
          ),
          Text(
            '${_monthNames[_focusedMonth.month]}  ${_focusedMonth.year}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 15,
                fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary,
            onPressed: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _weekdays.map((d) => Expanded(
          child: Center(
            child: Text(d, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(EventProvider eventProvider) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, childAspectRatio: 1.1),
      itemCount: totalCells,
      itemBuilder: (ctx, index) {
        final dayNumber = index - startOffset + 1;

        // Greyed out days from adjacent months
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          final prevDays =
              DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
          final label = dayNumber < 1
              ? '${prevDays + dayNumber}'
              : '${dayNumber - daysInMonth}';
          return Center(
            child: Text(label, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                color: Color(0xFFCCCCCC))),
          );
        }

        final thisDay =
            DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final events = eventProvider.eventsForDay(thisDay);
        final isToday = _isSameDay(thisDay, today);
        final isSelected = _isSameDay(thisDay, _selectedDay);

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = thisDay),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$dayNumber',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : isToday
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
                        color: isSelected
                            ? Colors.white
                            : _statusColor(e.status),
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _legendDot(AppColors.attended, 'Going'),
          const SizedBox(width: 16),
          _legendDot(AppColors.maybe, 'Maybe'),
          const SizedBox(width: 16),
          _legendDot(AppColors.notAttended, 'Not going'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 11,
            color: Color(0xFF6B6B6B))),
      ],
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded,
              size: 56, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text('No events this day',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
                  fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 6),
          Text('Tap + to add one',
              style: TextStyle(fontFamily: 'Poppins',
                  fontSize: 13, color: Colors.grey[400])),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-event'),
            icon: const Icon(Icons.add),
            label: const Text('Add event to your calendar',
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Styled event card (from day_detail_screen style)
  // ─────────────────────────────────────────────
  Widget _buildEventCard(EventModel event) {
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
      onDismissed: (_) =>
          context.read<EventProvider>().deleteEvent(event.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: Icon(_statusIcon(event.status),
                    color: color, size: 22),
              ),
              const SizedBox(width: 12),
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
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 12,
                              color: Color(0xFF6B6B6B))),
                      if (event.time.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(event.time,
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 12,
                                color: Color(0xFF6B6B6B))),
                      ],
                    ]),
                  ],
                ),
              ),
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