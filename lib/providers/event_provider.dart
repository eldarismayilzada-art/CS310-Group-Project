import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<EventModel>>? _subscription;
  String? _currentUserId;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
          a.month == b.month &&
          a.day == b.day;
  }

  List<EventModel> eventsForDay(DateTime day) {
    return _events.where((e) => isSameDay(e.date, day)).toList();
  }

  void listenToEvents(String userId) {
    if (_currentUserId == userId && _subscription != null) return;
    _subscription?.cancel();
    _currentUserId = userId;
    print("LISTENING USER ID: $userId");
    _isLoading = true;
    notifyListeners();

    _subscription = _eventService.getEvents(userId).listen(
      (events) {
        _events = events;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _eventService.createEvent(event);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String eventId, AttendanceStatus status) async {
    try {
      await _eventService.updateStatus(eventId, status);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}