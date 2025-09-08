import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../widgets/event_tile.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Events',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    Text('🎂', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Birthdays'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'exam',
                child: Row(
                  children: [
                    Text('📚', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Exams'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'poya',
                child: Row(
                  children: [
                    Text('🌕', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text('Poya Days'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'custom',
                child: Row(
                  children: [
                    Text('📅', style: TextStyle(fontSize: 20)),
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
          return _buildEmptyState(context, theme);
        }

        return Column(
          children: [
            // Filter and search info
            if (eventController.searchQuery.isNotEmpty ||
                eventController.filterType != null)
              _buildFilterInfo(eventController, theme),

            // Toggle show past events
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${events.length} event${events.length != 1 ? 's' : ''}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: Icon(
                      eventController.showPastEvents
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 16,
                    ),
                    label: Text(
                      eventController.showPastEvents
                          ? 'Hide Past'
                          : 'Show Past',
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
                color: theme.colorScheme.primary,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventTile(
                      event: event,
                      onTap: () =>
                          Get.to(() => EventDetailScreen(event: event)),
                      onEdit: () =>
                          Get.to(() => AddEventScreen(eventToEdit: event)),
                      onDelete: () => eventController.deleteEvent(event.id),
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
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.event_note_rounded,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Events Found',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Try adjusting your filters or add some events to get started!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo(EventController controller, ThemeData theme) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              parts.join(' • '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear_rounded, size: 20),
            onPressed: () {
              controller.clearSearch();
              controller.clearFilter();
            },
            tooltip: 'Clear filters',
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
          title: const Text('Search Events'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter event name or description...',
              prefixIcon: Icon(Icons.search_rounded),
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
            TextButton(
              onPressed: () {
                controller.searchEvents(searchQuery.trim());
                Navigator.of(context).pop();
              },
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
}
