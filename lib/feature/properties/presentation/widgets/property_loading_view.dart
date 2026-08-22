import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyLoadingView extends StatelessWidget {
  const PropertyLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('property-loading-view'),
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
          _PropertyLoadingCard(colors: colors),
          if (index != 2) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _PropertyLoadingCard extends StatelessWidget {
  const _PropertyLoadingCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218.h,
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
              _PropertySkeleton(width: 55.r, height: 55.r, radius: 19.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PropertySkeleton(width: 145.w, height: 15.h),
                    SizedBox(height: 8.h),
                    _PropertySkeleton(width: 78.w, height: 9.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const _PropertySkeleton(width: double.infinity, height: 10),
          SizedBox(height: 15.h),
          _PropertySkeleton(width: double.infinity, height: 56.h, radius: 14.r),
          SizedBox(height: 16.h),
          const _PropertySkeleton(width: double.infinity, height: 8),
        ],
      ),
    );
  }
}

class _PropertySkeleton extends StatelessWidget {
  const _PropertySkeleton({
    required this.width,
    required this.height,
    this.radius = 99,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
