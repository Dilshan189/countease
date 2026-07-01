import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null && !widget.isLoading) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null && !widget.isLoading) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null && !widget.isLoading) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height ?? 50,
              child: widget.isOutlined
                  ? OutlinedButton(
                      onPressed: widget.isLoading ? null : _handlePress,
                      style: OutlinedButton.styleFrom(
                        padding: widget.padding ??
                            const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              widget.borderRadius ?? BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: widget.backgroundColor ?? AppColors.primaryIndigo,
                          width: 1.5,
                        ),
                      ),
                      child: _buildButtonContent(theme),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: widget.backgroundColor == null
                            ? AppGradients.primaryGradient
                            : null,
                        color: widget.backgroundColor,
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(14),
                        boxShadow: widget.onPressed != null
                            ? [
                                BoxShadow(
                                  color: (widget.backgroundColor ??
                                          AppColors.primaryIndigo)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : _handlePress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor:
                              widget.textColor ?? Colors.white,
                          shadowColor: Colors.transparent,
                          padding: widget.padding ??
                              const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                          shape: RoundedRectangleBorder(
                            borderRadius: widget.borderRadius ??
                                BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _buildButtonContent(theme),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _handlePress() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final contentColor = widget.isOutlined
        ? (widget.backgroundColor ?? AppColors.primaryIndigo)
        : (widget.textColor ?? Colors.white);

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Theme(
            data: ThemeData(
              iconTheme: IconThemeData(color: contentColor),
            ),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: theme.textTheme.titleSmall?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: contentColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.secondary,
      textColor: theme.colorScheme.onSecondary,
      icon: icon,
      isLoading: isLoading,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.danger,
      textColor: Colors.white,
      icon: icon,
      isLoading: isLoading,
    );
  }
}

class OutlinedCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final Color? borderColor;

  const OutlinedCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: borderColor,
      icon: icon,
      isLoading: isLoading,
      isOutlined: true,
    );
  }
}
