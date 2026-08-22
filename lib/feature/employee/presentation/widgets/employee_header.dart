import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({super.key, required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Tooltip(
          message: 'Back to dashboard',
          child: Material(
            color: colors.surfaceContainerLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(15.r),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(15.r),
              child: Container(
                width: 43.r,
                height: 43.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.48),
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(Icons.arrow_back_rounded, size: 20.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEAM DIRECTORY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'People & access',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('employee-add-button'),
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16.r),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    Color.lerp(colors.primary, colors.secondary, 0.45)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.24),
                    blurRadius: 16.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: colors.onPrimary, size: 19.r),
                  SizedBox(width: 4.w),
                  Text(
                    'Add',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
