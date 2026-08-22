import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TenantHeader extends StatelessWidget {
  const TenantHeader({super.key, required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        _HeaderButton(
          tooltip: 'Back to dashboard',
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TENANT DIRECTORY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.45,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'People & leases',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('tenant-add-button'),
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16.r),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    Color.lerp(colors.primary, colors.secondary, 0.45)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.24),
                    blurRadius: 16.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: colors.onPrimary, size: 19.r),
                  SizedBox(width: 4.w),
                  Text(
                    'Add',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surfaceContainerLow.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(15.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            width: 43.r,
            height: 43.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.48),
              ),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(icon, size: 20.r),
          ),
        ),
      ),
    );
  }
}
