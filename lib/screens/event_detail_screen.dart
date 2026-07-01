import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.event.isToday) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () => _editEvent(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, size: 20, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Immersive Hero Section
                _buildHeroSection(theme, isDark),
                // Details Section
                _buildDetailsSection(theme, isDark),
                // Actions
                _buildActionButtons(theme),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isDark) {
    return Container(
      height: 420,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _getEventGradient(),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Event Emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    widget.event.typeEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                widget.event.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Type name badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.event.typeName.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              // Countdown timer display
              _buildCountdownDisplay(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay(ThemeData theme) {
    if (widget.event.isToday) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _confettiController.play();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: AppDecorations.innerGlass(borderRadius: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                'TODAY IS THE DAY! 🎉',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.event.hasPassed && !widget.event.repeatYearly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: AppDecorations.innerGlass(borderRadius: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              'Event Has Passed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final days = _timeRemaining['days'] ?? 0;
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;
    final seconds = _timeRemaining['seconds'] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) _buildTimeUnit(days.toString(), 'Days', theme),
        if (days > 0 || hours > 0) _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours', theme),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Min', theme),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Sec', theme),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppDecorations.innerGlass(borderRadius: 14),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Event Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Detail list cards
          _buildDetailCard(
            Icons.calendar_today_rounded,
            'Date & Time',
            _formatFullDate(),
            theme,
            isDark,
          ),
          _buildDetailCard(
            Icons.hourglass_bottom_rounded,
            'Time Remaining Info',
            _getDetailedTimeRemaining(),
            theme,
            isDark,
          ),
          _buildDetailCard(
            Icons.add_circle_outline_rounded,
            'Created On',
            DateFormat('EEEE, MMMM d, y').format(widget.event.createdAt),
            theme,
            isDark,
          ),

          // Description Card
          if (widget.event.description != null && widget.event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                widget.event.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
            ),
          ],

          // Notification settings
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsSwitch(
            Icons.repeat_rounded,
            'Repeat Yearly',
            widget.event.repeatYearly,
            theme,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildSettingsSwitch(
            Icons.notifications_active_rounded,
            'Notifications Status',
            widget.event.notificationEnabled,
            theme,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String title,
    String value,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryIndigo, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSwitch(
    IconData icon,
    String title,
    bool value,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.primaryIndigo : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: value ? AppColors.success : Colors.grey,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Share Countdown',
              onPressed: _shareEvent,
              icon: const Icon(Icons.share_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedCustomButton(
              text: 'Edit Details',
              onPressed: _editEvent,
              icon: const Icon(Icons.edit_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getEventGradient() {
    switch (widget.event.type) {
      case EventType.birthday:
        return AppGradients.birthdayGradient;
      case EventType.exam:
        return AppGradients.examGradient;
      case EventType.poya:
        return AppGradients.poyaGradient;
      case EventType.custom:
        return AppGradients.customGradient;
    }
  }

  String _formatFullDate() {
    final eventDate = widget.event.eventDate;
    final eventTime = widget.event.eventTime;
    final dateStr = DateFormat('EEEE, MMMM d, y').format(eventDate);
    if (eventTime != null) {
      final hour = eventTime.hour.toString().padLeft(2, '0');
      final min = eventTime.minute.toString().padLeft(2, '0');
      return '$dateStr at $hour:$min';
    }
    return dateStr;
  }

  String _getDetailedTimeRemaining() {
    final days = _timeRemaining['days'] ?? 0;
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;

    if (widget.event.isToday) return 'Today!';
    if (widget.event.hasPassed && !widget.event.repeatYearly) return 'Passed';

    final parts = <String>[];
    if (days > 0) parts.add('$days day${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0 && days == 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');

    return parts.isEmpty ? 'Less than a minute' : parts.join(', ');
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
    final eventDateStr = DateFormat('MMMM d, y').format(widget.event.eventDate);
    final text = '''
⏰ CountEase - Countdown Active!
🎯 ${widget.event.typeEmoji} ${widget.event.title}
📅 Target: $eventDateStr
⏳ Time Left: ${_getDetailedTimeRemaining()}

Shared via CountEase App
'''.trim();
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Countdown details copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryIndigo,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _duplicateEvent() {
    final duplicated = Event(
      id: _eventController.generateEventId(),
      title: '${widget.event.title} (Copy)',
      eventDate: widget.event.eventDate.add(const Duration(days: 365)),
      type: widget.event.type,
      repeatYearly: widget.event.repeatYearly,
      notificationEnabled: widget.event.notificationEnabled,
      description: widget.event.description,
    );
    Get.to(() => AddEventScreen(eventToEdit: duplicated));
  }

  void _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${widget.event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _eventController.deleteEvent(widget.event.id);
      if (success) {
        Get.back();
      }
    }
  }
}
