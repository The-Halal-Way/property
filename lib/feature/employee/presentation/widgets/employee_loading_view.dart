import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeLoadingView extends StatelessWidget {
  const EmployeeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('employee-loading-view'),
      children: [
        Container(
          height: 216.h,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.48),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.r),
              topRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
              bottomRight: Radius.circular(30.r),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        for (var index = 0; index < 3; index++) ...[
          _EmployeeLoadingCard(colors: colors),
          if (index != 2) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _EmployeeLoadingCard extends StatelessWidget {
  const _EmployeeLoadingCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205.h,
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _EmployeeSkeleton(width: 54.r, height: 54.r, radius: 19.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EmployeeSkeleton(width: 140.w, height: 15.h),
                    SizedBox(height: 8.h),
                    _EmployeeSkeleton(width: 88.w, height: 9.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 19.h),
          const _EmployeeSkeleton(width: double.infinity, height: 10),
          SizedBox(height: 12.h),
          const _EmployeeSkeleton(width: double.infinity, height: 10),
          SizedBox(height: 16.h),
          _EmployeeSkeleton(width: double.infinity, height: 38.h, radius: 13.r),
        ],
      ),
    );
  }
}

class _EmployeeSkeleton extends StatelessWidget {
  const _EmployeeSkeleton({
    required this.width,
    required this.height,
    this.radius = 99,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
