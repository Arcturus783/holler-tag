import 'package:flutter/material.dart';
import 'package:myapp/elements/app_theme.dart'; // Adjust the import path

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final LinearGradient? gradient;
  final Color? backgroundColor; // Keep backgroundColor for solid color option

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final currentGradient = gradient ?? AppTheme.getDefaultGradient(context);
    final buttonBackgroundColor = backgroundColor ?? Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? currentGradient, // Use default if no gradient is provided
        borderRadius: borderRadius ?? BorderRadius.circular(35.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(35.0),
          ),
          elevation: elevation,
          foregroundColor: Colors.white,
        ),
        child: child,
      ),
    );
  }
}