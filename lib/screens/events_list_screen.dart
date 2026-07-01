import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../widgets/event_tile.dart';
import '../theme/app_theme.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Countdown Events',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context, eventController),
            tooltip: 'Search events',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter events',
            onSelected: (value) => _handleFilterAction(value, eventController),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('All Events'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'birthday',
                child: Row(
                  children: [
                    Text('🎂', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 12),
                    Text('Birthdays'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'exam',
                child: Row(
                  children: [
                    Text('📚', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 12),
                    Text('Exams'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'poya',
                child: Row(
                  children: [
                    Text('🌕', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 12),
                    Text('Poya Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'custom',
                child: Row(
                  children: [
                    Text('📅', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 12),
                    Text('Custom'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (eventController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = eventController.filteredEvents;

        if (events.isEmpty) {
          return _buildEmptyState(context, theme, isDark);
        }

        return Column(
          children: [
            // Filter and search info banner
            if (eventController.searchQuery.isNotEmpty ||
                eventController.filterType != null)
              _buildFilterInfo(eventController, theme, isDark),

            // Toggle show past events row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${events.length} countdown${events.length != 1 ? 's' : ''}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: Icon(
                      eventController.showPastEvents
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 16,
                      color: AppColors.primaryIndigo,
                    ),
                    label: Text(
                      eventController.showPastEvents ? 'Hide Past' : 'Show Past',
                      style: const TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: eventController.toggleShowPastEvents,
                  ),
                ],
              ),
            ),

            // Events list
            Expanded(
              child: RefreshIndicator(
                onRefresh: eventController.refreshEvents,
                color: AppColors.primaryIndigo,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: events.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventTile(
                      key: ValueKey(event.id),
                      event: event,
                      onTap: () => Get.to(() => EventDetailScreen(event: event)),
                      onEdit: () => Get.to(() => AddEventScreen(eventToEdit: event)),
                      onDelete: () => _confirmDelete(event, eventController),
                    );
                  },
                ),
              ),
            ),
          ],
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
                Icons.event_note_rounded,
                size: 72,
                color: AppColors.primaryIndigo.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Found',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search query, changing filters, or adding a new countdown to begin!',
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

  Widget _buildFilterInfo(EventController controller, ThemeData theme, bool isDark) {
    final parts = <String>[];
    if (controller.searchQuery.isNotEmpty) {
      parts.add('Search: "${controller.searchQuery}"');
    }
    if (controller.filterType != null) {
      parts.add('Type: ${controller.filterType!.name}');
    }
    if (controller.showPastEvents) {
      parts.add('Including past events');
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primaryIndigo,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parts.join(' • '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.clearSearch();
              controller.clearFilter();
            },
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, EventController controller) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = controller.searchQuery;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Search Events'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter search text...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => searchQuery = value,
            onSubmitted: (value) {
              controller.searchEvents(value.trim());
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.searchEvents(searchQuery.trim());
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _handleFilterAction(String action, EventController controller) {
    switch (action) {
      case 'all':
        controller.clearFilter();
        break;
      case 'birthday':
        controller.setFilterType(EventType.birthday);
        break;
      case 'exam':
        controller.setFilterType(EventType.exam);
        break;
      case 'poya':
        controller.setFilterType(EventType.poya);
        break;
      case 'custom':
        controller.setFilterType(EventType.custom);
        break;
    }
  }

  void _confirmDelete(Event event, EventController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteEvent(event.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
