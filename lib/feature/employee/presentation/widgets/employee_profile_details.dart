import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/presentation/widgets/employee_info_row.dart';

class EmployeeProfileDetails extends StatelessWidget {
  const EmployeeProfileDetails({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmployeeInfoRow(
          icon: Icons.work_rounded,
          label: 'Designation',
          value: employee.displayDesignation,
          accent: colors.primary,
        ),
        if (employee.email.isNotEmpty) ...[
          SizedBox(height: 10.h),
          EmployeeInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: employee.email,
            accent: colors.secondary,
          ),
        ],
        if (employee.phone.isNotEmpty) ...[
          SizedBox(height: 10.h),
          EmployeeInfoRow(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: employee.phone,
            accent: const Color(0xFF10B981),
          ),
        ],
        SizedBox(height: 15.h),
        Wrap(
          spacing: 7.w,
          runSpacing: 7.h,
          children: [
            _EmployeeDetailChip(
              icon: Icons.apartment_rounded,
              label: '${employee.propertiesCount} properties',
              accent: colors.secondary,
            ),
            for (final role in employee.roleLabels)
              _EmployeeDetailChip(
                icon: Icons.admin_panel_settings_rounded,
                label: role,
                accent: colors.primary,
              ),
          ],
        ),
        if (employee.notes.isNotEmpty) ...[
          SizedBox(height: 15.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
            ),
            child: Text(
              employee.notes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.sp,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
        SizedBox(height: 17.h),
        Row(
          children: [
            Icon(Icons.key_rounded, size: 16.r, color: colors.primary),
            SizedBox(width: 6.w),
            Text(
              'Permissions',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${employee.permissions.length} granted',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.h),
        if (employee.permissions.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              'No direct permissions are assigned.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          )
        else
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: employee.permissions
                .map(
                  (permission) => _EmployeeDetailChip(
                    icon: Icons.check_circle_outline_rounded,
                    label: permission,
                    accent: const Color(0xFF10B981),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _EmployeeDetailChip extends StatelessWidget {
  const _EmployeeDetailChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: accent),
          SizedBox(width: 5.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
