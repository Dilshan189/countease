import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import '../widgets/custom_button.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventController = Get.find<EventController>();
  Timer? _timer;
  Map<String, int> _timeRemaining = {};

  @override
  void initState() {
    super.initState();
    _updateCountdown();

    // Update every second for real-time countdown
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (mounted) {
      setState(() {
        _timeRemaining = widget.event.timeRemaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editEvent(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Countdown
            _buildHeroSection(theme),

            // Event Details Section
            _buildDetailsSection(theme),

            // Action Buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      height: 480,
      decoration: BoxDecoration(gradient: _getEventGradient()),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.event.typeEmoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),

              const SizedBox(height: 16),

              // Event Title
              Center(
                child: Text(
                  widget.event.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // Event Type
              Center(
                child: Text(
                  widget.event.typeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Countdown or Status
              Expanded(child: Center(child: _buildCountdownDisplay(theme))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay(ThemeData theme) {
    if (widget.event.isToday) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'Today is the day!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    if (widget.event.hasPassed && !widget.event.repeatYearly) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            'Event has passed',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Countdown display
    final days = _timeRemaining['days'] ?? 0;
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;
    final seconds = _timeRemaining['seconds'] ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large countdown numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (days > 0) _buildTimeUnit(days.toString(), 'Days', theme),
            if (days > 0 || hours > 0)
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours', theme),
            _buildTimeUnit(
              minutes.toString().padLeft(2, '0'),
              'Minutes',
              theme,
            ),
            _buildTimeUnit(
              seconds.toString().padLeft(2, '0'),
              'Seconds',
              theme,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Simplified text
        Text(
          _getSimplifiedCountdown(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Event Date
          _buildDetailItem(
            icon: Icons.calendar_today,
            title: 'Event Date',
            subtitle: DateFormat(
              'EEEE, MMMM d, y',
            ).format(widget.event.eventDate),
            theme: theme,
          ),

          // Time until event
          _buildDetailItem(
            icon: Icons.access_time,
            title: 'Time Remaining',
            subtitle: _getDetailedTimeRemaining(),
            theme: theme,
          ),

          // Created date
          _buildDetailItem(
            icon: Icons.add_circle_outline,
            title: 'Created',
            subtitle: DateFormat('MMM d, y').format(widget.event.createdAt),
            theme: theme,
          ),

          // Last updated
          if (widget.event.updatedAt != widget.event.createdAt)
            _buildDetailItem(
              icon: Icons.update,
              title: 'Last Updated',
              subtitle: DateFormat('MMM d, y').format(widget.event.updatedAt),
              theme: theme,
            ),

          // Description
          if (widget.event.description != null &&
              widget.event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.event.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],

          // Settings
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.repeat,
            title: 'Repeat Yearly',
            isEnabled: widget.event.repeatYearly,
            theme: theme,
          ),

          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            isEnabled: widget.event.notificationEnabled,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required bool isEnabled,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isEnabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled
                ? Colors.green
                : theme.colorScheme.onSurface.withOpacity(0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Share Event',
                  onPressed: _shareEvent,
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedCustomButton(
                  text: 'Edit Event',
                  onPressed: _editEvent,
                  icon: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getEventGradient() {
    switch (widget.event.type) {
      case EventType.birthday:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        );
      case EventType.exam:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        );
      case EventType.poya:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        );
      case EventType.custom:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
        );
    }
  }

  String _getSimplifiedCountdown() {
    final days = _timeRemaining['days'] ?? 0;

    if (days > 365) {
      final years = (days / 365).floor();
      return 'About $years year${years > 1 ? 's' : ''} to go';
    }

    if (days > 30) {
      final months = (days / 30).floor();
      return 'About $months month${months > 1 ? 's' : ''} to go';
    }

    if (days > 7) {
      final weeks = (days / 7).floor();
      return 'About $weeks week${weeks > 1 ? 's' : ''} to go';
    }

    if (days == 1) {
      return 'Tomorrow!';
    }

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} to go';
    }

    return 'Less than a day to go!';
  }

  String _getDetailedTimeRemaining() {
    final days = _timeRemaining['days'] ?? 0;
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;

    if (widget.event.isToday) {
      return 'Today!';
    }

    if (widget.event.hasPassed && !widget.event.repeatYearly) {
      return 'Event has passed';
    }

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days day${days > 1 ? 's' : ''}');
    }

    if (hours > 0) {
      parts.add('$hours hour${hours > 1 ? 's' : ''}');
    }

    if (minutes > 0 && days == 0) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }

    if (parts.isEmpty) {
      return 'Less than a minute';
    }

    return parts.join(', ');
  }

  void _editEvent() {
    Get.to(() => AddEventScreen(eventToEdit: widget.event));
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareEvent();
        break;
      case 'duplicate':
        _duplicateEvent();
        break;
      case 'delete':
        _deleteEvent();
        break;
    }
  }

  void _shareEvent() {
    final text = _generateShareText();
    Clipboard.setData(ClipboardData(text: text));

    Get.snackbar(
      'Copied!',
      'Event details copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  String _generateShareText() {
    final eventDate = DateFormat('MMMM d, y').format(widget.event.eventDate);
    final timeRemaining = _getDetailedTimeRemaining();

    return '''
🎯 ${widget.event.typeEmoji} ${widget.event.title}

📅 Date: $eventDate
⏰ Time Remaining: $timeRemaining
${widget.event.repeatYearly ? '🔄 Repeats yearly' : ''}

${widget.event.description ?? ''}

Shared from CountEase app
'''
        .trim();
  }

  void _duplicateEvent() {
    final duplicatedEvent = Event(
      id: _eventController.generateEventId(),
      title: '${widget.event.title} (Copy)',
      eventDate: widget.event.eventDate.add(
        const Duration(days: 365),
      ), // Next year
      type: widget.event.type,
      repeatYearly: widget.event.repeatYearly,
      notificationEnabled: widget.event.notificationEnabled,
      description: widget.event.description,
    );

    Get.to(() => AddEventScreen(eventToEdit: duplicatedEvent));
  }

  void _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${widget.event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _eventController.deleteEvent(widget.event.id);
      if (success) {
        Get.back(); // Go back to previous screen
      }
    }
  }
}
