import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../widgets/countdown_card.dart';
import '../widgets/event_tile.dart';
import '../models/event_model.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, eventController),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, eventController),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 20),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
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
        final upcomingEvents = eventController.upcomingEvents;

        if (events.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: eventController.refreshEvents,
          child: CustomScrollView(
            slivers: [
              // Search and filter info
              if (eventController.searchQuery.isNotEmpty ||
                  eventController.filterType != null)
                SliverToBoxAdapter(
                  child: _buildFilterInfo(eventController, theme),
                ),

              // Featured upcoming event (next event) or selected event
              SliverToBoxAdapter(
                child: Obx(() {
                  final selectedEvent = eventController.selectedEvent;
                  final displayEvent =
                      selectedEvent ??
                      (upcomingEvents.isNotEmpty ? upcomingEvents.first : null);

                  if (displayEvent != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          // Header showing if it's selected or upcoming
                          if (selectedEvent != null)

                          CountdownCard(
                            event: displayEvent,
                            onTap: () => _navigateToEventDetail(displayEvent),
                            showDetails: true,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              // Today's events section
              if (eventController.todayEvents.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildTodayEventsSection(
                    eventController.todayEvents,
                    theme,
                  ),
                ),

              // Events list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'All Events',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(
                          eventController.showPastEvents
                              ? Icons.visibility_off
                              : Icons.visibility,
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
              ),

              // Events list
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = events[index];
                  return EventTile(
                    event: event,
                    onTap: () => eventController.selectEvent(event),
                    onEdit: () => _navigateToEditEvent(event),
                    onDelete: () => _deleteEvent(event, eventController),
                  );
                }, childCount: events.length),
              ),

              // Bottom padding for navigation bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 90,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

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
                Icons.event_available,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by adding your first countdown event!\nBirthdays, exams, special occasions - track them all.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 25,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  "Add Event Text",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo(EventController controller, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterText(controller),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () {
              controller.clearSearch();
              controller.clearFilter();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEventsSection(List<Event> todayEvents, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.today, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Today\'s Events',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: todayEvents.length,
            itemBuilder: (context, index) {
              final event = todayEvents[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToEventDetail(event),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                event.typeEmoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.celebration,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Today!',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getFilterText(EventController controller) {
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

    return parts.join(' • ');
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
              prefixIcon: Icon(Icons.search),
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

  void _handleMenuAction(String action, EventController controller) {
    switch (action) {
      case 'filter':
        _showFilterDialog(controller);
        break;
      case 'settings':
        Get.to(() => const SettingsScreen());
        break;
    }
  }

  void _showFilterDialog(EventController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Types'),
                leading: Radio<EventType?>(
                  value: null,
                  groupValue: controller.filterType,
                  onChanged: (value) {
                    controller.setFilterType(value);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ...EventType.values.map(
                (type) => ListTile(
                  title: Text('${_getTypeEmoji(type)} ${_getTypeName(type)}'),
                  leading: Radio<EventType?>(
                    value: type,
                    groupValue: controller.filterType,
                    onChanged: (value) {
                      controller.setFilterType(value);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
        return 'Birthday';
      case EventType.exam:
        return 'Exam';
      case EventType.poya:
        return 'Poya';
      case EventType.custom:
        return 'Custom';
    }
  }

  void _navigateToAddEvent() {
    Get.to(() => const AddEventScreen());
  }

  void _navigateToEditEvent(Event event) {
    Get.to(() => AddEventScreen(eventToEdit: event));
  }

  void _navigateToEventDetail(Event event) {
    Get.to(() => EventDetailScreen(event: event));
  }

  void _deleteEvent(Event event, EventController controller) {
    controller.deleteEvent(event.id);
  }
}
