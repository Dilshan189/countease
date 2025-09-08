import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';

class DatabaseService {
  static const String _eventsBoxName = 'events';
  static const String _settingsBoxName = 'settings';

  static Box<Event>? _eventsBox;
  static Box? _settingsBox;

  // Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(EventTypeAdapter());

    // Open boxes
    _eventsBox = await Hive.openBox<Event>(_eventsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Getters for boxes
  static Box<Event> get eventsBox {
    if (_eventsBox == null) {
      throw Exception(
        'Events box not initialized. Call DatabaseService.init() first.',
      );
    }
    return _eventsBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null) {
      throw Exception(
        'Settings box not initialized. Call DatabaseService.init() first.',
      );
    }
    return _settingsBox!;
  }

  // Event CRUD operations
  static Future<void> addEvent(Event event) async {
    await eventsBox.put(event.id, event);
  }

  static List<Event> getAllEvents() {
    return eventsBox.values.toList();
  }

  static Event? getEvent(String id) {
    return eventsBox.get(id);
  }

  static Future<void> updateEvent(Event event) async {
    event.updatedAt = DateTime.now();
    await eventsBox.put(event.id, event);
  }

  static Future<void> deleteEvent(String id) async {
    await eventsBox.delete(id);
  }

  static Future<void> deleteAllEvents() async {
    await eventsBox.clear();
  }

  // Get events sorted by date
  static List<Event> getEventsSortedByDate({bool ascending = true}) {
    final events = getAllEvents();
    events.sort((a, b) {
      if (ascending) {
        return a.eventDate.compareTo(b.eventDate);
      } else {
        return b.eventDate.compareTo(a.eventDate);
      }
    });
    return events;
  }

  // Get upcoming events (not passed and sorted by date)
  static List<Event> getUpcomingEvents() {
    final events = getAllEvents();
    final now = DateTime.now();

    return events.where((event) {
      if (event.repeatYearly) {
        return true; // Yearly events are always upcoming
      }
      return event.eventDate.isAfter(now) || event.isToday;
    }).toList()..sort((a, b) {
      DateTime aDate = a.eventDate;
      DateTime bDate = b.eventDate;

      // Handle yearly repeating events
      if (a.repeatYearly && aDate.isBefore(now)) {
        aDate = DateTime(now.year + 1, aDate.month, aDate.day);
      }
      if (b.repeatYearly && bDate.isBefore(now)) {
        bDate = DateTime(now.year + 1, bDate.month, bDate.day);
      }

      return aDate.compareTo(bDate);
    });
  }

  // Get events by type
  static List<Event> getEventsByType(EventType type) {
    return getAllEvents().where((event) => event.type == type).toList();
  }

  // Settings operations
  static Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await settingsBox.delete(key);
  }

  // Theme settings
  static Future<void> setDarkMode(bool isDark) async {
    await setSetting('darkMode', isDark);
  }

  static bool getDarkMode() {
    return getSetting<bool>('darkMode', defaultValue: false) ?? false;
  }

  // Notification settings
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await setSetting('notificationsEnabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return getSetting<bool>('notificationsEnabled', defaultValue: true) ?? true;
  }

  // Backup and restore
  static Map<String, dynamic> exportData() {
    final events = getAllEvents();
    final settings = Map<String, dynamic>.from(settingsBox.toMap());

    return {
      'events': events
          .map(
            (event) => {
              'id': event.id,
              'title': event.title,
              'eventDate': event.eventDate.toIso8601String(),
              'type': event.type.toString(),
              'repeatYearly': event.repeatYearly,
              'notificationEnabled': event.notificationEnabled,
              'description': event.description,
              'createdAt': event.createdAt.toIso8601String(),
              'updatedAt': event.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'settings': settings,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await deleteAllEvents();
      await settingsBox.clear();

      // Import events
      if (data['events'] != null) {
        for (final eventData in data['events']) {
          final event = Event(
            id: eventData['id'],
            title: eventData['title'],
            eventDate: DateTime.parse(eventData['eventDate']),
            type: EventType.values.firstWhere(
              (e) => e.toString() == eventData['type'],
              orElse: () => EventType.custom,
            ),
            repeatYearly: eventData['repeatYearly'] ?? false,
            notificationEnabled: eventData['notificationEnabled'] ?? true,
            description: eventData['description'],
            createdAt: DateTime.parse(eventData['createdAt']),
            updatedAt: DateTime.parse(eventData['updatedAt']),
          );
          await addEvent(event);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        for (final entry in data['settings'].entries) {
          await setSetting(entry.key, entry.value);
        }
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  // Close database
  static Future<void> close() async {
    await _eventsBox?.close();
    await _settingsBox?.close();
  }
}
