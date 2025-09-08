import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';

class EventController extends GetxController {
  // Observable lists and variables
  final RxList<Event> _events = <Event>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<EventType?> _filterType = Rx<EventType?>(null);
  final RxBool _showPastEvents = false.obs;

  // Getters
  List<Event> get events => _events;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  EventType? get filterType => _filterType.value;
  bool get showPastEvents => _showPastEvents.value;

  // Filtered events based on search and filter criteria
  List<Event> get filteredEvents {
    List<Event> filtered = List.from(_events);

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.title.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ) ||
            event.description?.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ==
                true;
      }).toList();
    }

    // Filter by event type
    if (_filterType.value != null) {
      filtered = filtered
          .where((event) => event.type == _filterType.value)
          .toList();
    }

    // Filter past events
    if (!_showPastEvents.value) {
      filtered = filtered
          .where((event) => !event.hasPassed || event.repeatYearly)
          .toList();
    }

    // Sort by event date (upcoming first)
    filtered.sort((a, b) {
      final now = DateTime.now();
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

    return filtered;
  }

  // Get upcoming events (next 5)
  List<Event> get upcomingEvents {
    final upcoming = filteredEvents
        .where((event) => !event.hasPassed || event.repeatYearly)
        .toList();
    return upcoming.take(5).toList();
  }

  // Get events by type with count
  Map<EventType, int> get eventTypeCounts {
    final counts = <EventType, int>{};
    for (final type in EventType.values) {
      counts[type] = _events.where((event) => event.type == type).length;
    }
    return counts;
  }

  // Get today's events
  List<Event> get todayEvents {
    final today = DateTime.now();
    return _events.where((event) {
      if (event.repeatYearly) {
        return event.eventDate.month == today.month &&
            event.eventDate.day == today.day;
      }
      return event.isToday;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();

    // Refresh events every minute to update countdowns
    ever(_events, (_) => update());
  }

  // Load all events from database
  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      final events = DatabaseService.getAllEvents();
      _events.assignAll(events);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load events: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Add new event
  Future<bool> addEvent(Event event) async {
    try {
      _isLoading.value = true;

      // Request notification permissions first if notifications are enabled
      if (event.notificationEnabled) {
        try {
          await NotificationService.requestPermissions();
        } catch (e) {
          debugPrint('Permission request failed: $e');
        }
      }

      // Add to database
      await DatabaseService.addEvent(event);

      // Schedule notifications
      if (event.notificationEnabled) {
        try {
          await NotificationService.scheduleEventNotifications(event);
        } catch (e) {
          debugPrint('Notification scheduling failed: $e');
          // Don't fail event creation if notifications fail
        }
      }

      // Add to local list
      _events.add(event);

      Get.snackbar(
        'Success',
        'Event "${event.title}" added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add event: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Update existing event
  Future<bool> updateEvent(Event event) async {
    try {
      _isLoading.value = true;

      // Update in database
      await DatabaseService.updateEvent(event);

      // Update notifications
      await NotificationService.cancelEventNotifications(event.id);
      if (event.notificationEnabled) {
        try {
          await NotificationService.scheduleEventNotifications(event);
        } catch (e) {
          debugPrint('Notification scheduling failed: $e');
          // Don't fail event update if notifications fail
        }
      }

      // Update in local list
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
      }

      Get.snackbar(
        'Success',
        'Event "${event.title}" updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      _isLoading.value = true;

      // Get event for notification
      final event = _events.firstWhereOrNull((e) => e.id == eventId);

      // Remove from database
      await DatabaseService.deleteEvent(eventId);

      // Cancel notifications
      await NotificationService.cancelEventNotifications(eventId);

      // Remove from local list
      _events.removeWhere((e) => e.id == eventId);

      if (event != null) {
        Get.snackbar(
          'Success',
          'Event "${event.title}" deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete event: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get event by ID
  Event? getEventById(String id) {
    return _events.firstWhereOrNull((event) => event.id == id);
  }

  // Search events
  void searchEvents(String query) {
    _searchQuery.value = query;
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
  }

  // Set filter type
  void setFilterType(EventType? type) {
    _filterType.value = type;
  }

  // Clear filter
  void clearFilter() {
    _filterType.value = null;
  }

  // Toggle show past events
  void toggleShowPastEvents() {
    _showPastEvents.value = !_showPastEvents.value;
  }

  // Refresh events (pull to refresh)
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  // Generate unique ID for new events
  String generateEventId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Bulk operations
  Future<void> deleteAllEvents() async {
    try {
      _isLoading.value = true;

      // Cancel all notifications
      await NotificationService.cancelAllNotifications();

      // Clear database
      await DatabaseService.deleteAllEvents();

      // Clear local list
      _events.clear();

      Get.snackbar(
        'Success',
        'All events deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete all events: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Export events data
  Map<String, dynamic> exportEvents() {
    return DatabaseService.exportData();
  }

  // Import events data
  Future<bool> importEvents(Map<String, dynamic> data) async {
    try {
      _isLoading.value = true;

      final success = await DatabaseService.importData(data);
      if (success) {
        await loadEvents();
        await NotificationService.scheduleAllEventNotifications();

        Get.snackbar(
          'Success',
          'Events imported successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to import events',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to import events: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Schedule notifications for all events
  Future<void> scheduleAllNotifications() async {
    try {
      await NotificationService.scheduleAllEventNotifications();
      Get.snackbar(
        'Success',
        'Notifications scheduled for all events!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to schedule notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
