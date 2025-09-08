import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (eventController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = eventController.events;

        if (events.isEmpty) {
          return _buildEmptyState(context, theme);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(events, theme),
              const SizedBox(height: 20),
              _buildEventTypesCard(eventController, theme),
              const SizedBox(height: 20),
              _buildUpcomingEventsCard(eventController, theme),
              const SizedBox(height: 20),
              _buildTimeInsightsCard(events, theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Statistics Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add some events to see your statistics and insights!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(List<Event> events, ThemeData theme) {
    final totalEvents = events.length;
    final upcomingEvents = events
        .where((e) => !e.hasPassed || e.repeatYearly)
        .length;
    final todayEvents = events.where((e) => e.isToday).length;
    final passedEvents = events
        .where((e) => e.hasPassed && !e.repeatYearly)
        .length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                    Icons.event_rounded,
                    theme.colorScheme.primary,
                    theme,
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Upcoming',
                    upcomingEvents.toString(),
                    Icons.schedule_rounded,
                    Colors.blue,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Today',
                    todayEvents.toString(),
                    Icons.today_rounded,
                    Colors.green,
                    theme,
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    passedEvents.toString(),
                    Icons.check_circle_rounded,
                    Colors.grey,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypesCard(EventController controller, ThemeData theme) {
    final typeCounts = controller.eventTypeCounts;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Event Types',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                child: _buildTypeProgress(type, count, percentage, theme),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeProgress(
    EventType type,
    int count,
    int percentage,
    ThemeData theme,
  ) {
    final typeEmoji = _getTypeEmoji(type);
    final typeName = _getTypeName(type);
    final color = _getTypeColor(type);

    return Column(
      children: [
        Row(
          children: [
            Text(typeEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                typeName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsCard(EventController controller, ThemeData theme) {
    final upcomingEvents = controller.upcomingEvents.take(3).toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upcoming_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Next Events',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (upcomingEvents.isEmpty)
              Text(
                'No upcoming events',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              )
            else
              ...upcomingEvents.map(
                (event) => _buildUpcomingEventItem(event, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventItem(Event event, ThemeData theme) {
    final daysUntil = event.daysUntilEvent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(event.typeEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  event.typeName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysUntil == 0 ? 'Today' : '$daysUntil days',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInsightsCard(List<Event> events, ThemeData theme) {
    final now = DateTime.now();
    final thisMonth = events
        .where(
          (e) => e.eventDate.month == now.month && e.eventDate.year == now.year,
        )
        .length;
    final nextMonth = events
        .where((e) => e.eventDate.month == (now.month % 12) + 1)
        .length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Time Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                    Icons.calendar_month,
                    Colors.blue,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightItem(
                    'Next Month',
                    nextMonth.toString(),
                    Icons.next_plan,
                    Colors.green,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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
        return Colors.pink;
      case EventType.exam:
        return Colors.blue;
      case EventType.poya:
        return Colors.purple;
      case EventType.custom:
        return Colors.orange;
    }
  }
}
