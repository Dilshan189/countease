import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

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

class _CountdownCardState extends State<CountdownCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Map<String, int> _timeRemaining = {};
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _updateCountdown();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    final duration = widget.showSeconds
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);
    _timer = Timer.periodic(duration, (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shimmerController.dispose();
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: AppDecorations.gradientCard(
            gradient: _getGradient(),
            borderRadius: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Shimmer overlay
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned(
                      left: -200 + (_shimmerController.value * 600),
                      top: 0,
                      bottom: 0,
                      width: 200,
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event header
                      _buildHeader(theme),
                      const SizedBox(height: 20),
                      // Countdown display
                      if (widget.event.isToday)
                        _buildTodayWidget(theme)
                      else if (widget.event.hasPassed &&
                          !widget.event.repeatYearly)
                        _buildPassedWidget(theme)
                      else
                        _buildCountdownWidget(theme),
                      // Details section
                      if (widget.showDetails) ...[
                        const SizedBox(height: 16),
                        _buildDetails(theme),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Emoji in glass circle
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              widget.event.typeEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
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
              const SizedBox(height: 2),
              Text(
                widget.event.typeName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        // Arrow icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.innerGlass(borderRadius: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            'Today is the day! 🎉',
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
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.innerGlass(borderRadius: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            'Event has passed',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
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

    return Column(
      children: [
        // Time unit pills in glass containers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (days > 0) _buildTimeUnitPill(days.toString(), 'Days', theme),
            if (days > 0 || hours > 0)
              _buildTimeUnitPill(
                hours.toString().padLeft(2, '0'),
                'Hours',
                theme,
              ),
            if (days > 0 || hours > 0 || minutes > 0)
              _buildTimeUnitPill(
                minutes.toString().padLeft(2, '0'),
                'Min',
                theme,
              ),
            if (widget.showSeconds)
              _buildTimeUnitPill(
                seconds.toString().padLeft(2, '0'),
                'Sec',
                theme,
              ),
          ],
        ),
        // Simplified countdown text
        if (days > 7) ...[
          const SizedBox(height: 14),
          Text(
            _getSimplifiedCountdown(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTimeUnitPill(
    String value,
    String label,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDecorations.innerGlass(borderRadius: 14),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(ThemeData theme) {
    final eventDate = widget.event.eventDate;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final formattedDate =
        '${eventDate.day} ${months[eventDate.month - 1]}, ${eventDate.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.innerGlass(borderRadius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              if (widget.event.repeatYearly)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Yearly',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
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
                color: Colors.white.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
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
