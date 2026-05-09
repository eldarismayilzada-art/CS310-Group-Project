import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<EventModel> eventsForDay(DateTime day) {
    return _events.where((e) =>
      e.date.year == day.year &&
      e.date.month == day.month &&
      e.date.day == day.day).toList();
  }

  void listenToEvents(String userId) {
    _isLoading = true;
    notifyListeners();

    _eventService.getEvents(userId).listen(
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
    }
  }

  Future<void> updateStatus(
      String eventId, AttendanceStatus status) async {
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
}