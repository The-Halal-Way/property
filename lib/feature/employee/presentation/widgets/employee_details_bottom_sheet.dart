import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/feature/employee/data/model/employee_model.dart';
import 'package:property/feature/employee/presentation/widgets/employee_avatar.dart';
import 'package:property/feature/employee/presentation/widgets/employee_login_badge.dart';
import 'package:property/feature/employee/presentation/widgets/employee_profile_details.dart';

Future<void> showEmployeeDetailsBottomSheet({
  required BuildContext context,
  required EmployeeModel employee,
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
        _EmployeeDetailsBottomSheet(employee: employee, accent: accent),
  );
}

class _EmployeeDetailsBottomSheet extends StatelessWidget {
  const _EmployeeDetailsBottomSheet({
    required this.employee,
    required this.accent,
  });

  final EmployeeModel employee;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.74,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      snap: true,
      snapSizes: const [0.4, 0.74, 0.94],
      builder: (context, scrollController) => Material(
        key: ValueKey('employee-details-sheet-${employee.id}'),
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
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        EmployeeLoginBadge(enabled: employee.loginEnabled),
                      ],
                    ),
                  ),
                  IconButton(
                    key: ValueKey('employee-details-close-${employee.id}'),
                    tooltip: 'Close profile',
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
                child: EmployeeProfileDetails(employee: employee),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
