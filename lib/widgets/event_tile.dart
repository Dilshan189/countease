import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool compact;

  const EventTile({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: compact ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title and type emoji
              Row(
                children: [
                  Text(
                    event.typeEmoji,
                    style: TextStyle(fontSize: compact ? 20 : 24),
                  ),
                  SizedBox(width: compact ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style:
                              (compact
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!compact)
                          Text(
                            event.typeName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (showActions && !compact)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              SizedBox(height: compact ? 8 : 12),

              // Event date and countdown
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: compact ? 14 : 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: compact ? 3 : 4),
                  Text(
                    _formatEventDate(),
                    style:
                        (compact
                                ? theme.textTheme.bodySmall
                                : theme.textTheme.bodySmall)
                            ?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getCountdownColor(colorScheme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCountdownText(),
                      style:
                          (compact
                                  ? theme.textTheme.labelSmall
                                  : theme.textTheme.bodySmall)
                              ?.copyWith(
                                color: _getCountdownTextColor(colorScheme),
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                ],
              ),

              // Description if available
              if (!compact &&
                  event.description != null &&
                  event.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Status indicators
              if (!compact) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (event.repeatYearly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Yearly',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (event.repeatYearly) const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: event.notificationEnabled
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: event.notificationEnabled
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.notificationEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            size: 12,
                            color: event.notificationEnabled
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            event.notificationEnabled ? 'Notify' : 'Silent',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: event.notificationEnabled
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatEventDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${event.eventDate.day} ${months[event.eventDate.month - 1]}, ${event.eventDate.year}';
  }

  String _getCountdownText() {
    if (event.isToday) {
      return 'Today!';
    }

    final daysUntil = event.daysUntilEvent;

    if (daysUntil < 0 && !event.repeatYearly) {
      return 'Passed';
    }

    if (daysUntil == 1) {
      return 'Tomorrow';
    }

    if (daysUntil < 7) {
      return '$daysUntil days';
    }

    if (daysUntil < 30) {
      final weeks = (daysUntil / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    }

    if (daysUntil < 365) {
      final months = (daysUntil / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    }

    final years = (daysUntil / 365).floor();
    return '$years year${years > 1 ? 's' : ''}';
  }

  Color _getCountdownColor(ColorScheme colorScheme) {
    if (event.isToday) {
      return Colors.green.withOpacity(0.2);
    }

    final daysUntil = event.daysUntilEvent;

    if (daysUntil < 0 && !event.repeatYearly) {
      return Colors.grey.withOpacity(0.2);
    }

    if (daysUntil <= 1) {
      return Colors.orange.withOpacity(0.2);
    }

    if (daysUntil <= 7) {
      return Colors.yellow.withOpacity(0.2);
    }

    return colorScheme.primary.withOpacity(0.1);
  }

  Color _getCountdownTextColor(ColorScheme colorScheme) {
    if (event.isToday) {
      return Colors.green;
    }

    final daysUntil = event.daysUntilEvent;

    if (daysUntil < 0 && !event.repeatYearly) {
      return Colors.grey;
    }

    if (daysUntil <= 1) {
      return Colors.orange;
    }

    if (daysUntil <= 7) {
      return Colors.amber[700]!;
    }

    return colorScheme.primary;
  }
}
