import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isRefreshing;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      Color.lerp(colors.primary, colors.tertiary, 0.48)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(6.r),
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(15.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.2),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.space_dashboard_rounded,
                  color: colors.onPrimary,
                  size: 21.r,
                ),
              ),
              SizedBox(width: 11.w),
              Text(
                'Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Semantics(
          button: true,
          label: 'Refresh dashboard',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isRefreshing ? null : onRefresh,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(7.r),
                bottomLeft: Radius.circular(7.r),
                bottomRight: Radius.circular(18.r),
              ),
              child: Ink(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(7.r),
                    bottomLeft: Radius.circular(7.r),
                    bottomRight: Radius.circular(15.r),
                  ),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.58),
                  ),
                ),
                child: isRefreshing
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primary,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: colors.primary,
                        size: 20.r,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
