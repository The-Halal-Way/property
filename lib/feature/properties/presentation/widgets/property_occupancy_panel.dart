import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_model.dart';

class PropertyOccupancyPanel extends StatelessWidget {
  const PropertyOccupancyPanel({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final percent = (property.occupancyRate * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Occupancy',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${property.occupiedUnitsCount}/${property.resolvedUnitsCount} units  ·  $percent%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface,
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 7.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            minHeight: 7.h,
            value: property.occupancyRate,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(colors.secondary, colors.primary, 0.42)!,
            ),
          ),
        ),
      ],
    );
  }
}
