import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 10.h),
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.09),
                      offset: Offset(0, 8.h),
                      blurRadius: 24.r,
                    ),
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.07),
                      offset: Offset(0, -2.h),
                      blurRadius: 16.r,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.space_dashboard_rounded,
                        label: 'Dashboard',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.tune_rounded,
                        label: 'Settings',
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedEnd = Color.lerp(colors.primary, colors.secondary, 0.55)!;

    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected ? null : Colors.transparent,
              gradient: isSelected
                  ? LinearGradient(
                      colors: [colors.primary, selectedEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25),
                        blurRadius: 14.r,
                        offset: Offset(0, 5.h),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.onPrimary.withValues(alpha: 0.16)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    size: 17.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
