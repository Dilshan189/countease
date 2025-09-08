import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';

class CountdownCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool showSeconds;

  const CountdownCard({
    super.key,
    required this.event,
    this.onTap,
    this.showDetails = true,
    this.showSeconds = false,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;
  Map<String, int> _timeRemaining = {};

  @override
  void initState() {
    super.initState();
    _updateCountdown();

    // Update every second if showing seconds, otherwise every minute
    final duration = widget.showSeconds
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);

    _timer = Timer.periodic(duration, (_) => _updateCountdown());
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

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _getGradient(colorScheme),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event header
              Row(
                children: [
                  Text(
                    widget.event.typeEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.event.typeName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Countdown display
              if (widget.event.isToday)
                _buildTodayWidget(theme)
              else if (widget.event.hasPassed && !widget.event.repeatYearly)
                _buildPassedWidget(theme)
              else
                _buildCountdownWidget(theme),

              if (widget.showDetails) ...[
                const SizedBox(height: 16),
                _buildDetails(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            'Today is the day!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassedWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            'Event has passed',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownWidget(ThemeData theme) {
    final days = _timeRemaining['days'] ?? 0;
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;
    final seconds = _timeRemaining['seconds'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Main countdown display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (days > 0) _buildTimeUnit(days.toString(), 'Days', theme),
              if (days > 0 || hours > 0)
                _buildTimeUnit(
                  hours.toString().padLeft(2, '0'),
                  'Hours',
                  theme,
                ),
              if (days > 0 || hours > 0 || minutes > 0)
                _buildTimeUnit(
                  minutes.toString().padLeft(2, '0'),
                  'Minutes',
                  theme,
                ),
              if (widget.showSeconds)
                _buildTimeUnit(
                  seconds.toString().padLeft(2, '0'),
                  'Seconds',
                  theme,
                ),
            ],
          ),

          // Simplified display for large countdowns
          if (days > 7) ...[
            const SizedBox(height: 12),
            Text(
              _getSimplifiedCountdown(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
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

  Widget _buildDetails(ThemeData theme) {
    final eventDate = widget.event.eventDate;
    final formattedDate =
        '${eventDate.day}/${eventDate.month}/${eventDate.year}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              if (widget.event.repeatYearly)
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Yearly',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (widget.event.description != null &&
              widget.event.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.event.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getGradient(ColorScheme colorScheme) {
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
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        );
    }
  }

  String _getSimplifiedCountdown() {
    final days = _timeRemaining['days'] ?? 0;

    if (days > 365) {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      return '$years year${years > 1 ? 's' : ''} and $remainingDays day${remainingDays > 1 ? 's' : ''}';
    }

    if (days > 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      return '$months month${months > 1 ? 's' : ''} and $remainingDays day${remainingDays > 1 ? 's' : ''}';
    }

    if (days > 7) {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;
      return '$weeks week${weeks > 1 ? 's' : ''} and $remainingDays day${remainingDays > 1 ? 's' : ''}';
    }

    return '';
  }
}
