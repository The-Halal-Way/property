import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_avatar.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_details_bottom_sheet.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_info_row.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_status_badge.dart';

class TenantCard extends StatelessWidget {
  const TenantCard({super.key, required this.tenant, required this.accent});

  final TenantModel tenant;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      key: ValueKey('tenant-card-${tenant.id}'),
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
                      TenantAvatar(initials: tenant.initials, accent: accent),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.25,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'TENANT  #${tenant.id}',
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
                      TenantStatusBadge(isActive: tenant.hasActiveLease),
                    ],
                  ),
                  if (tenant.phone.isNotEmpty) ...[
                    SizedBox(height: 15.h),
                    TenantInfoRow(
                      icon: Icons.phone_rounded,
                      value: tenant.phone,
                      accent: accent,
                    ),
                  ],
                  if (tenant.email.isNotEmpty) ...[
                    SizedBox(height: 9.h),
                    TenantInfoRow(
                      icon: Icons.alternate_email_rounded,
                      value: tenant.email,
                      accent: colors.secondary,
                    ),
                  ],
                  if (tenant.fullAddress.isNotEmpty) ...[
                    SizedBox(height: 9.h),
                    TenantInfoRow(
                      icon: Icons.location_on_rounded,
                      value: tenant.fullAddress,
                      accent: colors.tertiary,
                    ),
                  ],
                  SizedBox(height: 5.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      key: ValueKey('tenant-details-${tenant.id}'),
                      onPressed: () => showTenantDetailsBottomSheet(
                        context: context,
                        tenant: tenant,
                        accent: accent,
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: Icon(Icons.keyboard_arrow_up_rounded, size: 18.r),
                      label: const Text('View details'),
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
