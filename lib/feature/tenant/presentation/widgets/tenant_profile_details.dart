import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/tenant/data/model/tenant_model.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_detail_chip.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_info_row.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_lease_section.dart';

class TenantProfileDetails extends StatelessWidget {
  const TenantProfileDetails({super.key, required this.tenant});

  final TenantModel tenant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasDocument =
        tenant.idDocumentType.isNotEmpty || tenant.idDocumentNumber.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7.w,
          runSpacing: 7.h,
          children: [
            TenantDetailChip(
              icon: Icons.family_restroom_rounded,
              label: 'Family',
              value: '${tenant.familyMembersCount}',
            ),
            if (hasDocument)
              TenantDetailChip(
                icon: Icons.fingerprint_rounded,
                label: tenant.idDocumentType.isEmpty
                    ? 'ID'
                    : tenant.idDocumentType,
                value: tenant.idDocumentNumber.isEmpty
                    ? 'Not provided'
                    : tenant.idDocumentNumber,
              ),
          ],
        ),
        if (tenant.emergencyContactName.isNotEmpty ||
            tenant.emergencyContactPhone.isNotEmpty) ...[
          SizedBox(height: 13.h),
          TenantInfoRow(
            icon: Icons.emergency_rounded,
            label: 'Emergency contact${_relationSuffix(tenant)}',
            value: _joinedContact(
              tenant.emergencyContactName,
              tenant.emergencyContactPhone,
            ),
            accent: colors.tertiary,
          ),
        ],
        if (tenant.guardianName.isNotEmpty ||
            tenant.guardianPhone.isNotEmpty) ...[
          SizedBox(height: 10.h),
          TenantInfoRow(
            icon: Icons.shield_outlined,
            label: 'Guardian',
            value: _joinedContact(tenant.guardianName, tenant.guardianPhone),
            accent: colors.secondary,
          ),
        ],
        if (tenant.notes.isNotEmpty) ...[
          SizedBox(height: 13.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
            ),
            child: Text(
              tenant.notes,
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
            Icon(Icons.key_rounded, size: 16.r, color: colors.primary),
            SizedBox(width: 6.w),
            Text(
              'Lease timeline',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${tenant.leases.length} total',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.h),
        TenantLeaseSection(leases: tenant.leases),
      ],
    );
  }

  String _joinedContact(String name, String phone) {
    return [name, phone].where((part) => part.isNotEmpty).join('  •  ');
  }

  String _relationSuffix(TenantModel tenant) {
    return tenant.emergencyContactRelation.isEmpty
        ? ''
        : ' · ${tenant.emergencyContactRelation}';
  }
}
