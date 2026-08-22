import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TenantLoadingView extends StatelessWidget {
  const TenantLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('tenant-loading-view'),
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
          _LoadingCard(colors: colors),
          if (index != 2) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170.h,
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
              _SkeletonBox(width: 53.r, height: 53.r, radius: 18.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 140.w, height: 15.h),
                    SizedBox(height: 8.h),
                    _SkeletonBox(width: 72.w, height: 9.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 19.h),
          const _SkeletonBox(width: double.infinity, height: 10),
          SizedBox(height: 11.h),
          const _SkeletonBox(width: double.infinity, height: 10),
          SizedBox(height: 11.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _SkeletonBox(width: 180.w, height: 10.h),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
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
