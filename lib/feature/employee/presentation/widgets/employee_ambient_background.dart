import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeAmbientBackground extends StatelessWidget {
  const EmployeeAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _EmployeeGlow(
              color: colors.secondary,
              size: 270.r,
              top: -142.h,
              right: -120.w,
            ),
            _EmployeeGlow(
              color: colors.primary,
              size: 225.r,
              top: 365.h,
              left: -152.w,
            ),
            _EmployeeGlow(
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

class _EmployeeGlow extends StatelessWidget {
  const _EmployeeGlow({
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
