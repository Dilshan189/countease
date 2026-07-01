import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics & Stats',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (eventController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = eventController.events;

        if (events.isEmpty) {
          return _buildEmptyState(context, theme, isDark);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Card
              _buildOverviewCard(events, theme, isDark),
              const SizedBox(height: 20),

              // Event Categories list
              _buildEventTypesCard(eventController, theme, isDark),
              const SizedBox(height: 20),

              // Upcoming timeline highlights
              _buildUpcomingEventsCard(eventController, theme, isDark),
              const SizedBox(height: 20),

              // Time insights (this month/next month)
              _buildTimeInsightsCard(events, theme, isDark),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 72,
                color: AppColors.primaryIndigo.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Analytics Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some countdown events to generate statistics and category analytics!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(List<Event> events, ThemeData theme, bool isDark) {
    final totalEvents = events.length;
    final upcomingEvents = events.where((e) => !e.hasPassed || e.repeatYearly).length;
    final todayEvents = events.where((e) => e.isToday).length;
    final passedEvents = events.where((e) => e.hasPassed && !e.repeatYearly).length;

    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, color: AppColors.primaryIndigo, size: 22),
              const SizedBox(width: 8),
              Text(
                'Dashboard Overview',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Events',
                  totalEvents.toString(),
                  Icons.event_note_rounded,
                  AppColors.primaryIndigo,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Active Track',
                  upcomingEvents.toString(),
                  Icons.av_timer_rounded,
                  AppColors.accent,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Today Alerts',
                  todayEvents.toString(),
                  Icons.celebration_rounded,
                  AppColors.success,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'History Log',
                  passedEvents.toString(),
                  Icons.history_rounded,
                  Colors.grey,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypesCard(EventController controller, ThemeData theme, bool isDark) {
    final typeCounts = controller.eventTypeCounts;

    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category_rounded, color: AppColors.primaryIndigo, size: 22),
              const SizedBox(width: 8),
              Text(
                'Category Distribution',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...EventType.values.map((type) {
            final count = typeCounts[type] ?? 0;
            final percentage = controller.events.isNotEmpty
                ? (count / controller.events.length * 100).round()
                : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTypeProgress(type, count, percentage, theme, isDark),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeProgress(
    EventType type,
    int count,
    int percentage,
    ThemeData theme,
    bool isDark,
  ) {
    final typeEmoji = _getTypeEmoji(type);
    final typeName = _getTypeName(type);
    final color = _getTypeColor(type);

    return Column(
      children: [
        Row(
          children: [
            Text(typeEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                typeName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsCard(EventController controller, ThemeData theme, bool isDark) {
    final upcomingEvents = controller.upcomingEvents.take(3).toList();

    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upcoming_rounded, color: AppColors.primaryIndigo, size: 22),
              const SizedBox(width: 8),
              Text(
                'Next Countdown Goals',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcomingEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No upcoming goals found.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...upcomingEvents.map(
              (event) => _buildUpcomingEventItem(event, theme, isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventItem(Event event, ThemeData theme, bool isDark) {
    final daysUntil = event.daysUntilEvent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(event.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(event.typeEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  event.typeName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryIndigo.withValues(alpha: 0.15)),
            ),
            child: Text(
              daysUntil == 0 ? 'Today!' : '$daysUntil days',
              style: const TextStyle(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInsightsCard(List<Event> events, ThemeData theme, bool isDark) {
    final now = DateTime.now();
    final thisMonth = events.where((e) => e.eventDate.month == now.month && e.eventDate.year == now.year).length;
    final nextMonth = events.where((e) => e.eventDate.month == (now.month % 12) + 1).length;

    return Container(
      decoration: AppDecorations.elevatedCard(isDark: isDark, borderRadius: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryIndigo, size: 22),
              const SizedBox(width: 8),
              Text(
                'Timeline Insights',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'This Month',
                  thisMonth.toString(),
                  Icons.calendar_view_month_rounded,
                  AppColors.primaryIndigo,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Next Month',
                  nextMonth.toString(),
                  Icons.next_plan_rounded,
                  AppColors.accent,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textLightPrimary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeEmoji(EventType type) {
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

  String _getTypeName(EventType type) {
    switch (type) {
      case EventType.birthday:
        return 'Birthdays';
      case EventType.exam:
        return 'Exams';
      case EventType.poya:
        return 'Poya Days';
      case EventType.custom:
        return 'Custom Events';
    }
  }

  Color _getTypeColor(EventType type) {
    switch (type) {
      case EventType.birthday:
        return AppColors.birthdayStart;
      case EventType.exam:
        return AppColors.examStart;
      case EventType.poya:
        return AppColors.poyaStart;
      case EventType.custom:
        return AppColors.customStart;
    }
  }
}
