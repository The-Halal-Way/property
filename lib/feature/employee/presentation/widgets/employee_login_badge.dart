import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeLoginBadge extends StatelessWidget {
  const EmployeeLoginBadge({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = enabled ? const Color(0xFF10B981) : colors.outline;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: accent.withValues(alpha: 0.23)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
            size: 11.r,
            color: accent,
          ),
          SizedBox(width: 4.w),
          Text(
            enabled ? 'Login on' : 'Login off',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
