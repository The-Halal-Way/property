import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyTypeBadge extends StatelessWidget {
  const PropertyTypeBadge({
    super.key,
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: accent.withValues(alpha: 0.23)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
