import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final actions = <_QuickAction>[
      _QuickAction(
        label: 'Properties',
        icon: Icons.apartment_rounded,
        accent: colors.primary,
      ),
      _QuickAction(
        label: 'Tenants',
        icon: Icons.groups_rounded,
        accent: colors.secondary,
      ),
      _QuickAction(
        label: 'Invoices',
        icon: Icons.receipt_long_rounded,
        accent: colors.tertiary,
      ),
      _QuickAction(
        label: 'Reports',
        icon: Icons.query_stats_rounded,
        accent: Color.lerp(colors.primary, colors.secondary, 0.48)!,
      ),
      _QuickAction(
        label: 'Employees',
        icon: Icons.badge_rounded,
        accent: Color.lerp(colors.secondary, colors.tertiary, 0.36)!,
      ),
      _QuickAction(
        label: 'Roles & Permissions',
        icon: Icons.admin_panel_settings_rounded,
        accent: Color.lerp(colors.primary, colors.tertiary, 0.5)!,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 6
            : constraints.maxWidth >= 330
            ? 3
            : 2;
        final spacing = 8.w;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final tileHeight = columns == 2 ? 78.h : 88.h;

        return GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: tileWidth / tileHeight,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionTile(
              action: action,
              onTap: () => onSelected(action.label),
            );
          },
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      label: 'Open ${action.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('dashboard-quick-action-${action.label}'),
          onTap: onTap,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22.r),
            topRight: Radius.circular(8.r),
            bottomLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(22.r),
          ),
          child: Ink(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow.withValues(alpha: 0.86),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(22.r),
              ),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.54),
              ),
              boxShadow: [
                BoxShadow(
                  color: action.accent.withValues(alpha: 0.07),
                  blurRadius: 16.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(22.r),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(9.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 31.r,
                              height: 31.r,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    action.accent,
                                    Color.lerp(
                                      action.accent,
                                      colors.primary,
                                      0.38,
                                    )!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(11.r),
                                  topRight: Radius.circular(5.r),
                                  bottomLeft: Radius.circular(5.r),
                                  bottomRight: Radius.circular(11.r),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: action.accent.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 9.r,
                                    offset: Offset(0, 3.h),
                                  ),
                                ],
                              ),
                              child: Icon(
                                action.icon,
                                color: _foregroundFor(action.accent),
                                size: 17.r,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_outward_rounded,
                              size: 13.r,
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.56,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          action.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurface,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _foregroundFor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;
}
