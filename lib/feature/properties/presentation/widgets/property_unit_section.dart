import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_unit_model.dart';
import 'package:property/feature/properties/presentation/widgets/property_detail_chip.dart';

class PropertyUnitSection extends StatelessWidget {
  const PropertyUnitSection({
    super.key,
    required this.units,
    required this.currency,
  });

  final List<PropertyUnitModel> units;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (units.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          'No unit records are attached to this property.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 10.sp,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < units.length; index++) ...[
          _PropertyUnitTile(unit: units[index], currency: currency),
          if (index != units.length - 1) SizedBox(height: 9.h),
        ],
      ],
    );
  }
}

class _PropertyUnitTile extends StatelessWidget {
  const _PropertyUnitTile({required this.unit, required this.currency});

  final PropertyUnitModel unit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = unit.occupied
        ? const Color(0xFF10B981)
        : colors.tertiary;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surfaceContainerHighest.withValues(alpha: 0.42),
            colors.surfaceContainerLow.withValues(alpha: 0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.door_front_door_rounded,
                  size: 17.r,
                  color: colors.secondary,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      unit.condition.isEmpty
                          ? 'Condition not specified'
                          : _titleCase(unit.condition),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  unit.occupied ? 'Occupied' : 'Available',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              PropertyDetailChip(
                icon: Icons.bed_rounded,
                label: '${unit.bedrooms} bed',
              ),
              PropertyDetailChip(
                icon: Icons.bathtub_rounded,
                label: '${unit.bathrooms} bath',
              ),
              PropertyDetailChip(
                icon: Icons.kitchen_rounded,
                label: '${unit.kitchens} kitchen',
              ),
              PropertyDetailChip(
                icon: Icons.local_parking_rounded,
                label: '${unit.parkingSpaces} parking',
              ),
              if (unit.sizeLabel.isNotEmpty)
                PropertyDetailChip(
                  icon: Icons.straighten_rounded,
                  label: unit.sizeLabel,
                ),
            ],
          ),
          SizedBox(height: 11.h),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 15.r, color: colors.primary),
              SizedBox(width: 6.w),
              Text(
                'Default rent',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 8.5.sp,
                ),
              ),
              const Spacer(),
              Text(
                _rentLabel(unit),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (unit.occupied && unit.currentTenantId > 0) ...[
            SizedBox(height: 7.h),
            Text(
              'Current tenant  #${unit.currentTenantId}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (unit.amenities.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 5.w,
              runSpacing: 5.h,
              children: unit.amenities
                  .map(
                    (amenity) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Text(
                        amenity,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }

  String _rentLabel(PropertyUnitModel unit) {
    final amount = unit.defaultRentAmount.isEmpty
        ? 'Not set'
        : unit.defaultRentAmount;
    return currency.isEmpty || amount == 'Not set'
        ? amount
        : '$currency $amount';
  }

  String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
