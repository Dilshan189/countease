import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddPressed;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Calculate responsive height based on screen size
    final isSmallScreen = screenHeight < 700;
    final navBarHeight = isSmallScreen ? 70.0 : 80.0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: navBarHeight,
            maxHeight: navBarHeight + 10, // Allow slight flexibility
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: isSmallScreen ? 8 : 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Tab
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: currentIndex == 0,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(0);
                    },
                  ),
                ),

                // Events Tab
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    icon: Icons.event_note_rounded,
                    label: 'Events',
                    index: 1,
                    isSelected: currentIndex == 1,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(1);
                    },
                  ),
                ),

                // Center Add Button
                _buildCenterAddButton(context),

                // Statistics Tab
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    icon: Icons.analytics_rounded,
                    label: 'Stats',
                    index: 2,
                    isSelected: currentIndex == 2,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(2);
                    },
                  ),
                ),

                // Settings Tab
                Expanded(
                  child: _buildNavItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    index: 3,
                    isSelected: currentIndex == 3,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(3);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 4 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: isSmallScreen ? 20 : 24,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.6),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final buttonSize = isSmallScreen ? 56.0 : 64.0;
    final iconSize = isSmallScreen ? 28.0 : 32.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onAddPressed();
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, size: iconSize, color: Colors.white),
      ),
    );
  }
}
