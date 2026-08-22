import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_model.dart';

class PropertyValuePanel extends StatelessWidget {
  const PropertyValuePanel({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.075),
            colors.secondary.withValues(alpha: 0.055),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ValueMetric(
              label: 'Current value',
              value: property.moneyLabel(property.currentValue),
              icon: Icons.trending_up_rounded,
              accent: const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 34.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
          Expanded(
            child: _ValueMetric(
              label: 'Purchase price',
              value: property.moneyLabel(property.purchasePrice),
              icon: Icons.sell_rounded,
              accent: colors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueMetric extends StatelessWidget {
  const _ValueMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16.r, color: accent),
        SizedBox(width: 7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 8.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
