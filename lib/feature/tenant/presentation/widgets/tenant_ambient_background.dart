import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TenantAmbientBackground extends StatelessWidget {
  const TenantAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _GlowOrb(
              color: colors.secondary,
              size: 260.r,
              top: -130.h,
              right: -118.w,
            ),
            _GlowOrb(
              color: colors.primary,
              size: 230.r,
              top: 350.h,
              left: -155.w,
            ),
            _GlowOrb(
              color: colors.tertiary,
              size: 190.r,
              bottom: 30.h,
              right: -130.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
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
              blurRadius: 90.r,
              spreadRadius: 24.r,
            ),
          ],
        ),
      ),
    );
  }
}
