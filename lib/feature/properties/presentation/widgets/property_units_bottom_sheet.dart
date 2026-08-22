import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/properties/data/model/property_model.dart';
import 'package:property/feature/properties/presentation/widgets/property_details.dart';
import 'package:property/feature/properties/presentation/widgets/property_hero_icon.dart';
import 'package:property/feature/properties/presentation/widgets/property_type_badge.dart';

Future<void> showPropertyUnitsBottomSheet({
  required BuildContext context,
  required PropertyModel property,
  required Color accent,
}) {
  final colors = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: colors.scrim.withValues(alpha: 0.54),
    builder: (_) =>
        _PropertyUnitsBottomSheet(property: property, accent: accent),
  );
}

class _PropertyUnitsBottomSheet extends StatelessWidget {
  const _PropertyUnitsBottomSheet({
    required this.property,
    required this.accent,
  });

  final PropertyModel property;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.42,
      maxChildSize: 0.94,
      snap: true,
      snapSizes: const [0.42, 0.78, 0.94],
      builder: (context, scrollController) => Material(
        key: ValueKey('property-units-sheet-${property.id}'),
        color: colors.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: Column(
          children: [
            SizedBox(height: 9.h),
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 13.h, 10.w, 12.h),
              child: Row(
                children: [
                  PropertyHeroIcon(type: property.type, accent: accent),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Flexible(
                              child: PropertyTypeBadge(
                                label: property.displayType,
                                accent: accent,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              '${property.resolvedUnitsCount} units',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: ValueKey('property-units-close-${property.id}'),
                    tooltip: 'Close units',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 28.h),
                child: PropertyDetails(property: property),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
