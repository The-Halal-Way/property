import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_page_model.dart';

class PropertyOverviewCard extends StatelessWidget {
  const PropertyOverviewCard({super.key, required this.page});

  final PropertyPageModel page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = page.meta.total > 0
        ? page.meta.total
        : page.properties.length;

    return Container(
      key: const ValueKey('property-overview-card'),
      padding: EdgeInsets.fromLTRB(20.w, 19.h, 20.w, 18.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(colors.primary, Colors.black, 0.2)!,
            Color.lerp(colors.primary, colors.secondary, 0.58)!,
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
              right: -38.w,
              top: -54.h,
              child: Icon(
                Icons.apartment_rounded,
                size: 150.r,
                color: Colors.white.withValues(alpha: 0.08),
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
                    '◆  ASSET PULSE',
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
                  '$total properties.\nOne living portfolio.',
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
                      child: _PropertyMetric(
                        value: '${page.totalUnits}',
                        label: 'Total units',
                      ),
                    ),
                    const _PropertyMetricDivider(),
                    Expanded(
                      child: _PropertyMetric(
                        value: '${page.occupiedUnits}',
                        label: 'Occupied',
                      ),
                    ),
                    const _PropertyMetricDivider(),
                    Expanded(
                      child: _PropertyMetric(
                        value: '${page.vacantUnits}',
                        label: 'Available',
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

class _PropertyMetric extends StatelessWidget {
  const _PropertyMetric({required this.value, required this.label});

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

class _PropertyMetricDivider extends StatelessWidget {
  const _PropertyMetricDivider();

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
