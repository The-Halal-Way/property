import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TenantSectionHeader extends StatelessWidget {
  const TenantSectionHeader({
    super.key,
    required this.count,
    required this.isRefreshing,
  });

  final int count;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 5.r,
          height: 19.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Resident profiles',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isRefreshing) ...[
          SizedBox(width: 10.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 11.r,
                height: 11.r,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8.r,
                  color: colors.secondary,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Syncing',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
