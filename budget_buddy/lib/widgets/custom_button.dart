import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Professional custom button with multiple variants and animations
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return Container(
      width: widget.fullWidth ? double.infinity : null,
      padding: _getPadding(),
      decoration: _getDecoration(isEnabled),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: _getIconSize(),
              height: _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(isEnabled),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: _getIconSize(),
              color: _getTextColor(isEnabled),
            ),
            const SizedBox(width: 8),
          ],

          Text(widget.text, style: _getTextStyle(isEnabled)),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  BoxDecoration _getDecoration(bool isEnabled) {
    Color backgroundColor;
    Color borderColor;

    switch (widget.type) {
      case ButtonType.primary:
        backgroundColor = isEnabled ? AppTheme.primaryBlue : AppTheme.gray300;
        borderColor = backgroundColor;
        break;
      case ButtonType.secondary:
        backgroundColor =
            isEnabled ? AppTheme.secondaryGreen : AppTheme.gray300;
        borderColor = backgroundColor;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        borderColor = isEnabled ? AppTheme.primaryBlue : AppTheme.gray300;
        break;
      case ButtonType.ghost:
        backgroundColor = Colors.transparent;
        borderColor = Colors.transparent;
        break;
      case ButtonType.danger:
        backgroundColor = isEnabled ? AppTheme.error : AppTheme.gray300;
        borderColor = backgroundColor;
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
      boxShadow:
          widget.type == ButtonType.primary ||
                  widget.type == ButtonType.secondary
              ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
              : null,
    );
  }

  Color _getTextColor(bool isEnabled) {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
        return isEnabled ? AppTheme.primaryBlue : AppTheme.gray500;
      case ButtonType.ghost:
        return isEnabled ? AppTheme.gray700 : AppTheme.gray500;
    }
  }

  TextStyle _getTextStyle(bool isEnabled) {
    double fontSize;
    FontWeight fontWeight = FontWeight.w600;

    switch (widget.size) {
      case ButtonSize.small:
        fontSize = 12;
        break;
      case ButtonSize.medium:
        fontSize = 14;
        break;
      case ButtonSize.large:
        fontSize = 16;
        break;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: _getTextColor(isEnabled),
      letterSpacing: 0.1,
    );
  }
}

enum ButtonType { primary, secondary, outline, ghost, danger }

enum ButtonSize { small, medium, large }
