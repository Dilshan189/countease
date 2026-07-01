import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: AppDecorations.elevatedCard(
              isDark: isDark,
              borderRadius: 16,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Gradient accent strip
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: _getEventGradient(),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 12 : 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              children: [
                                // Emoji avatar
                                Container(
                                  width: compact ? 36 : 42,
                                  height: compact ? 36 : 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: _getEventGradient(),
                                  ),
                                  child: Center(
                                    child: Text(
                                      event.typeEmoji,
                                      style: TextStyle(
                                        fontSize: compact ? 18 : 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: compact ? 10 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: (compact
                                                ? theme.textTheme.titleSmall
                                                : theme.textTheme.titleMedium)
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (!compact)
                                        Text(
                                          event.typeName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: isDark
                                                    ? AppColors
                                                        .textDarkSecondary
                                                    : AppColors
                                                        .textLightSecondary,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Countdown badge
                                _buildCountdownBadge(theme, isDark),
                              ],
                            ),

                            SizedBox(height: compact ? 8 : 10),

                            // Date + status row
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: compact ? 12 : 14,
                                  color: isDark
                                      ? AppColors.textDarkSecondary
                                      : AppColors.textLightSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatEventDate(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textDarkSecondary
                                        : AppColors.textLightSecondary,
                                  ),
                                ),
                                const Spacer(),
                                // Status dots
                                if (!compact) ...[
                                  if (event.repeatYearly)
                                    _buildStatusDot(
                                      AppColors.primaryIndigo,
                                      'Yearly',
                                      theme,
                                    ),
                                  if (event.repeatYearly)
                                    const SizedBox(width: 12),
                                  _buildStatusDot(
                                    event.notificationEnabled
                                        ? AppColors.success
                                        : const Color(0xFF94A3B8),
                                    event.notificationEnabled
                                        ? 'Notify'
                                        : 'Silent',
                                    theme,
                                  ),
                                ],
                                if (showActions && !compact)
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      color: isDark
                                          ? AppColors.textDarkSecondary
                                          : AppColors.textLightSecondary,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
                                            Icon(Icons.edit_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_rounded,
                                              size: 18,
                                              color: AppColors.danger,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.danger,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Description
                            if (!compact &&
                                event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                event.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textDarkSecondary
                                      : AppColors.textLightSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownBadge(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: _getCountdownGradient(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getCountdownText(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 11,
        ),
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatEventDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${event.eventDate.day} ${months[event.eventDate.month - 1]}, ${event.eventDate.year}';
  }

  String _getCountdownText() {
    if (event.isToday) return 'Today!';

    final daysUntil = event.daysUntilEvent;

    if (daysUntil < 0 && !event.repeatYearly) return 'Passed';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil < 7) return '$daysUntil days';
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

  LinearGradient _getCountdownGradient() {
    if (event.isToday) {
      return const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
      );
    }

    final daysUntil = event.daysUntilEvent;

    if (daysUntil < 0 && !event.repeatYearly) {
      return const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF475569)],
      );
    }
    if (daysUntil <= 1) {
      return const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
      );
    }
    if (daysUntil <= 7) {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      );
    }
    return AppGradients.primaryGradient;
  }

  LinearGradient _getEventGradient() {
    switch (event.type) {
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
}
