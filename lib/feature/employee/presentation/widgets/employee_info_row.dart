import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeInfoRow extends StatelessWidget {
  const EmployeeInfoRow({
    super.key,
    required this.icon,
    required this.value,
    required this.accent,
    this.label,
  });

  final IconData icon;
  final String value;
  final Color accent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29.r,
          height: 29.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 14.r, color: accent),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 8.5.sp,
                  ),
                ),
                SizedBox(height: 1.h),
              ],
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
