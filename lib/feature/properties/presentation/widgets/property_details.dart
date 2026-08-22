import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/presentation/widgets/property_info_row.dart';
import 'package:property/feature/properties/presentation/widgets/property_unit_section.dart';

class PropertyDetails extends StatelessWidget {
  const PropertyDetails({super.key, required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (property.employeeId > 0)
          PropertyInfoRow(
            icon: Icons.badge_rounded,
            label: 'Assigned employee',
            value: 'Employee #${property.employeeId}',
            accent: colors.secondary,
          ),
        if (property.notes.isNotEmpty) ...[
          if (property.employeeId > 0) SizedBox(height: 11.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
            ),
            child: Text(
              property.notes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.sp,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
        SizedBox(height: 15.h),
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 16.r, color: colors.primary),
            SizedBox(width: 6.w),
            Text(
              'Unit directory',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${property.units.length} records',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.h),
        PropertyUnitSection(units: property.units, currency: property.currency),
      ],
    );
  }
}
