import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/presentation/widgets/employee_avatar.dart';
import 'package:property/feature/employee/presentation/widgets/employee_details_bottom_sheet.dart';
import 'package:property/feature/employee/presentation/widgets/employee_login_badge.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee, required this.accent});

  final EmployeeModel employee;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      key: ValueKey('employee-card-${employee.id}'),
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
              padding: EdgeInsets.fromLTRB(17.w, 16.h, 14.w, 11.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmployeeAvatar(
                        initials: employee.initials,
                        photoUrl: employee.photoUrl,
                        accent: accent,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.25,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              employee.displayDesignation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'EMPLOYEE  #${employee.id}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      EmployeeLoginBadge(enabled: employee.loginEnabled),
                    ],
                  ),
                  if (employee.email.isNotEmpty ||
                      employee.phone.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        if (employee.email.isNotEmpty)
                          Expanded(
                            child: _CompactEmployeeContact(
                              icon: Icons.alternate_email_rounded,
                              value: employee.email,
                              accent: colors.secondary,
                            ),
                          ),
                        if (employee.email.isNotEmpty &&
                            employee.phone.isNotEmpty)
                          SizedBox(width: 10.w),
                        if (employee.phone.isNotEmpty)
                          Expanded(
                            child: _CompactEmployeeContact(
                              icon: Icons.phone_rounded,
                              value: employee.phone,
                              accent: const Color(0xFF10B981),
                            ),
                          ),
                      ],
                    ),
                  ],
                  SizedBox(height: 13.h),
                  Container(
                    padding: EdgeInsets.fromLTRB(11.w, 8.h, 4.w, 8.h),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.32,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 15.r,
                          color: colors.primary,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '${employee.propertiesCount} properties',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16.h,
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          color: colors.outlineVariant,
                        ),
                        Expanded(
                          child: Text(
                            employee.primaryRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.secondary,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          key: ValueKey('employee-details-${employee.id}'),
                          onPressed: () => showEmployeeDetailsBottomSheet(
                            context: context,
                            employee: employee,
                            accent: accent,
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 15.r,
                          ),
                          label: const Text('Profile'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            visualDensity: VisualDensity.compact,
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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

class _CompactEmployeeContact extends StatelessWidget {
  const _CompactEmployeeContact({
    required this.icon,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.r, color: accent),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
