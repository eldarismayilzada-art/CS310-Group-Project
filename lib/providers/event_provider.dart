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

  // Hata mesajını temizlemek için yardımcı metod
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Belirli bir güne ait etkinlikleri filtrele
  List<EventModel> eventsForDay(DateTime day) {
    return _events.where((e) =>
      e.date.year == day.year &&
      e.date.month == day.month &&
      e.date.day == day.day).toList();
  }

  // DÜZELTİLDİ: getEvents -> getEventsByClub olarak güncellendi
  void listenToEvents(String userId) {
    _isLoading = true;
    _errorMessage = null; // Yeni dinleme başladığında hatayı sıfırla
    notifyListeners();

    _eventService.getEventsByClub(userId).listen(
      (eventList) {
        _events = eventList;
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

  // Tüm etkinlikleri dinlemek için (Öğrenciler için gerekebilir)
  void listenToAllEvents() {
    _isLoading = true;
    notifyListeners();

    _eventService.getAllEvents().listen((eventList) {
      _events = eventList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createEvent(EventModel event) async {
    try {
      _errorMessage = null;
      await _eventService.createEvent(event);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow; // UI katmanında da yakalamak istersen
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
}
