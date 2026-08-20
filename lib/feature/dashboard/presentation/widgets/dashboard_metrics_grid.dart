import 'package:flutter/material.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_metric_tile.dart';

class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({
    super.key,
    required this.properties,
    required this.units,
    required this.occupied,
    required this.vacant,
    required this.tenants,
    required this.activeLeases,
  });

  final int properties;
  final int units;
  final int occupied;
  final int vacant;
  final int tenants;
  final int activeLeases;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metrics = <_DashboardMetric>[
      _DashboardMetric(
        label: 'Properties',
        value: properties,
        icon: Icons.apartment_rounded,
        accent: colors.primary,
      ),
      _DashboardMetric(
        label: 'Units',
        value: units,
        icon: Icons.door_front_door_rounded,
        accent: colors.secondary,
      ),
      _DashboardMetric(
        label: 'Occupied',
        value: occupied,
        icon: Icons.check_circle_rounded,
        accent: Color.lerp(colors.secondary, colors.primary, 0.35)!,
      ),
      _DashboardMetric(
        label: 'Vacant',
        value: vacant,
        icon: Icons.key_rounded,
        accent: colors.tertiary,
      ),
      _DashboardMetric(
        label: 'Tenants',
        value: tenants,
        icon: Icons.groups_rounded,
        accent: Color.lerp(colors.primary, colors.tertiary, 0.46)!,
      ),
      _DashboardMetric(
        label: 'Leases',
        value: activeLeases,
        icon: Icons.description_rounded,
        accent: Color.lerp(colors.secondary, colors.tertiary, 0.38)!,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 760
            ? 6
            : width >= 330
            ? 3
            : 2;
        const spacing = 8.0;
        const tileHeight = 82.0;
        final tileWidth = (width - spacing * (columns - 1)) / columns;

        return GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: tileWidth / tileHeight,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return DashboardMetricTile(
              label: metric.label,
              value: metric.value,
              icon: metric.icon,
              accent: metric.accent,
            );
          },
        );
      },
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color accent;
}
