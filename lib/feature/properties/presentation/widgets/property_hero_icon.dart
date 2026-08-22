import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyHeroIcon extends StatelessWidget {
  const PropertyHeroIcon({super.key, required this.type, required this.accent});

  final String type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 55.r,
      height: 55.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, colors.primary, 0.5)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(21.r),
          topRight: Radius.circular(8.r),
          bottomLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(21.r),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.23),
            blurRadius: 15.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Icon(
        _iconForType(type),
        size: 27.r,
        color: ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
    );
  }

  IconData _iconForType(String rawType) {
    final normalized = rawType.toLowerCase();
    if (normalized.contains('house') || normalized.contains('villa')) {
      return Icons.villa_rounded;
    }
    if (normalized.contains('commercial') || normalized.contains('office')) {
      return Icons.business_center_rounded;
    }
    if (normalized.contains('land') || normalized.contains('plot')) {
      return Icons.landscape_rounded;
    }
    return Icons.apartment_rounded;
  }
}
