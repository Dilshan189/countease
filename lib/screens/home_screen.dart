import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../widgets/countdown_card.dart';
import '../widgets/event_tile.dart';
import '../controllers/navigation_controller.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CountEase',
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context, eventController),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) => _handleMenuAction(value, eventController),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 20),
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
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header Welcome Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track Your Moments ⏳',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Filter Status Banner
              if (eventController.searchQuery.isNotEmpty ||
                  eventController.filterType != null)
                SliverToBoxAdapter(
                  child: _buildFilterInfo(eventController, theme, isDark),
                ),

              // Category Quick Filters Scroll
              SliverToBoxAdapter(
                child: _buildQuickFilters(eventController, theme, isDark),
              ),

              // Featured Countdowns
              SliverToBoxAdapter(
                child: Obx(() {
                  final selectedEvent = eventController.selectedEvent;
                  final displayEvent = selectedEvent ??
                      (upcomingEvents.isNotEmpty ? upcomingEvents.first : null);

                  if (displayEvent != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                selectedEvent != null ? 'Selected Focus' : 'Next Big Event',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CountdownCard(
                          event: displayEvent,
                          onTap: () => _navigateToEventDetail(displayEvent),
                          showDetails: true,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),

              // Today's Events Section
              if (eventController.todayEvents.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildTodayEventsCard(
                    eventController.todayEvents,
                    theme,
                    eventController,
                    isDark,
                  ),
                ),

              // All Events List Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Countdown Events',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Get.find<NavigationController>().changeIndex(1);
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Events List View (SliverList to avoid nested scrolling issues)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = events[index];
                    return EventTile(
                      event: event,
                      onTap: () => _navigateToEventDetail(event),
                      onEdit: () => _navigateToEditEvent(event),
                      onDelete: () => _deleteEvent(event, eventController),
                    );
                  },
                  childCount: events.length,
                ),
              ),

              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 100,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                Icons.hourglass_empty_rounded,
                size: 72,
                color: AppColors.primaryIndigo.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'තවම සිදුවීම් කිසිවක් නැත.\nඔබගේ පළමු countdown එක එකතු කරන්න!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const AddEventScreen()),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo(EventController controller, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterText(controller),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.w600,
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

  Widget _buildQuickFilters(EventController controller, ThemeData theme, bool isDark) {
    final activeFilter = controller.filterType;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" filter chip
          _buildFilterChip(
            label: 'All',
            emoji: '✨',
            isSelected: activeFilter == null,
            onTap: () => controller.setFilterType(null),
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          ...EventType.values.map((type) {
            final isSelected = activeFilter == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: _getTypeName(type),
                emoji: _getTypeEmoji(type),
                isSelected: isSelected,
                onTap: () => controller.setFilterType(type),
                theme: theme,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
              ),
            ),
          ],
        ),
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
              hintText: 'Enter event name...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Filter Event Types'),
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

  void _navigateToEditEvent(Event event) {
    Get.to(() => AddEventScreen(eventToEdit: event));
  }

  void _navigateToEventDetail(Event event) {
    Get.to(() => EventDetailScreen(event: event));
  }

  void _deleteEvent(Event event, EventController controller) {
    controller.deleteEvent(event.id);
  }

  Widget _buildTodayEventsCard(
    List<Event> todayEvents,
    ThemeData theme,
    EventController controller,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.celebration_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                "Happening Today!",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${todayEvents.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final event = todayEvents[index];
              return EventTile(
                event: event,
                onTap: () => controller.selectEvent(event),
                onEdit: () => _navigateToEditEvent(event),
                onDelete: () => _deleteEvent(event, controller),
                compact: true,
                showActions: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
