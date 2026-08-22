import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeEmptyView extends StatelessWidget {
  const EmployeeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('employee-empty-view'),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 42.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.44),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76.r,
            height: 76.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.15),
                  colors.secondary.withValues(alpha: 0.15),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              size: 35.r,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Build your team',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'No employees have been added to this portfolio yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
