import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/tenant/data/model/tenant_page_model.dart';

class TenantOverviewCard extends StatelessWidget {
  const TenantOverviewCard({super.key, required this.page});

  final TenantPageModel page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = page.meta.total > 0 ? page.meta.total : page.tenants.length;

    return Container(
      key: const ValueKey('tenant-overview-card'),
      padding: EdgeInsets.fromLTRB(20.w, 19.h, 20.w, 18.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(colors.primary, Colors.black, 0.18)!,
            Color.lerp(colors.primary, colors.secondary, 0.55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: 26.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned(
              right: -34.w,
              top: -52.h,
              child: Container(
                width: 132.r,
                height: 132.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 12.r,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    '●  LIVE PORTFOLIO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  '$total people call\nyour properties home.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.13,
                    letterSpacing: -0.75,
                  ),
                ),
                SizedBox(height: 19.h),
                Row(
                  children: [
                    Expanded(
                      child: _OverviewMetric(
                        value: '${page.activeTenantCount}',
                        label: 'Active tenants',
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _OverviewMetric(
                        value: '${page.activeLeaseCount}',
                        label: 'Active leases',
                      ),
                    ),
                    const _MetricDivider(),
                    Expanded(
                      child: _OverviewMetric(
                        value: '${page.propertyCount}',
                        label: 'Properties',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34.h,
      margin: EdgeInsets.symmetric(horizontal: 9.w),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}
