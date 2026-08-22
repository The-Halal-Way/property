import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/presentation/widgets/property_hero_icon.dart';
import 'package:property/feature/properties/presentation/widgets/property_info_row.dart';
import 'package:property/feature/properties/presentation/widgets/property_occupancy_panel.dart';
import 'package:property/feature/properties/presentation/widgets/property_type_badge.dart';
import 'package:property/feature/properties/presentation/widgets/property_units_bottom_sheet.dart';
import 'package:property/feature/properties/presentation/widgets/property_value_panel.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, required this.accent});

  final PropertyModel property;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      key: ValueKey('property-card-${property.id}'),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26.r),
          topRight: Radius.circular(11.r),
          bottomLeft: Radius.circular(11.r),
          bottomRight: Radius.circular(26.r),
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.46),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.07),
            blurRadius: 20.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 18.h,
              bottom: 18.h,
              child: Container(
                width: 3.5.w,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(17.w, 16.h, 15.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PropertyHeroIcon(type: property.type, accent: accent),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.25,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'PROPERTY  #${property.id}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.75,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 88.w),
                        child: PropertyTypeBadge(
                          label: property.displayType,
                          accent: accent,
                        ),
                      ),
                    ],
                  ),
                  if (property.fullAddress.isNotEmpty) ...[
                    SizedBox(height: 15.h),
                    PropertyInfoRow(
                      icon: Icons.location_on_rounded,
                      value: property.fullAddress,
                      accent: colors.tertiary,
                    ),
                  ],
                  SizedBox(height: 13.h),
                  PropertyValuePanel(property: property),
                  SizedBox(height: 13.h),
                  PropertyOccupancyPanel(property: property),
                  SizedBox(height: 5.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: ValueKey('property-details-${property.id}'),
                      onPressed: () => showPropertyUnitsBottomSheet(
                        context: context,
                        property: property,
                        accent: accent,
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 18.r),
                      label: const Text('View units'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        visualDensity: VisualDensity.compact,
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
