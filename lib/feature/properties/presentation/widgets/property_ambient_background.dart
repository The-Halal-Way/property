import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyAmbientBackground extends StatelessWidget {
  const PropertyAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _PropertyGlow(
              color: colors.primary,
              size: 280.r,
              top: -148.h,
              right: -126.w,
            ),
            _PropertyGlow(
              color: colors.secondary,
              size: 225.r,
              top: 370.h,
              left: -150.w,
            ),
            _PropertyGlow(
              color: colors.tertiary,
              size: 185.r,
              bottom: 45.h,
              right: -125.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyGlow extends StatelessWidget {
  const _PropertyGlow({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final Color color;
  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.035),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.13),
              blurRadius: 92.r,
              spreadRadius: 24.r,
            ),
          ],
        ),
      ),
    );
  }
}
