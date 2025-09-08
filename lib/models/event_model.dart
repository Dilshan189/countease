import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
enum EventType {
  @HiveField(0)
  birthday,
  @HiveField(1)
  exam,
  @HiveField(2)
  poya,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime eventDate;

  @HiveField(3)
  EventType type;

  @HiveField(4)
  bool repeatYearly;

  @HiveField(5)
  bool notificationEnabled;

  @HiveField(6)
  String? description;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.type,
    this.repeatYearly = false,
    this.notificationEnabled = true,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Get the emoji for the event type
  String get typeEmoji {
    switch (type) {
      case EventType.birthday:
        return '🎂';
      case EventType.exam:
        return '📚';
      case EventType.poya:
        return '🌕';
      case EventType.custom:
        return '📅';
    }
  }

  // Get the display name for the event type
  String get typeName {
    switch (type) {
      case EventType.birthday:
        return 'Birthday';
      case EventType.exam:
        return 'Exam';
      case EventType.poya:
        return 'Poya';
      case EventType.custom:
        return 'Custom';
    }
  }

  // Calculate days until the event
  int get daysUntilEvent {
    final now = DateTime.now();
    DateTime targetDate = eventDate;

    // If it's a yearly repeat and the date has passed this year
    if (repeatYearly && targetDate.isBefore(now)) {
      targetDate = DateTime(now.year + 1, eventDate.month, eventDate.day);
    }

    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  // Check if the event is today
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  // Check if the event has passed
  bool get hasPassed {
    if (repeatYearly) return false; // Yearly events never really pass
    return eventDate.isBefore(DateTime.now());
  }

  // Get detailed time remaining
  Map<String, int> get timeRemaining {
    final now = DateTime.now();
    DateTime targetDate = eventDate;

    if (repeatYearly && targetDate.isBefore(now)) {
      targetDate = DateTime(now.year + 1, eventDate.month, eventDate.day);
    }

    final difference = targetDate.difference(now);

    return {
      'days': difference.inDays,
      'hours': difference.inHours % 24,
      'minutes': difference.inMinutes % 60,
      'seconds': difference.inSeconds % 60,
    };
  }

  // Copy with method for updating
  Event copyWith({
    String? id,
    String? title,
    DateTime? eventDate,
    EventType? type,
    bool? repeatYearly,
    bool? notificationEnabled,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      type: type ?? this.type,
      repeatYearly: repeatYearly ?? this.repeatYearly,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, eventDate: $eventDate, type: $type, repeatYearly: $repeatYearly)';
  }
}
