import 'package:flutter/material.dart';

class DashboardLoadingView extends StatelessWidget {
  const DashboardLoadingView({
    super.key,
    this.showOverview = true,
    this.showMetrics = true,
  });

  final bool showOverview;
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fill = colors.surfaceContainerHighest.withValues(alpha: 0.62);

    return Semantics(
      label: 'Loading dashboard',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.45, end: 0.78),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOut,
          builder: (context, opacity, child) {
            return Opacity(opacity: opacity, child: child);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showOverview)
                _SkeletonBox(height: 174, radius: 24, color: fill),
              if (showOverview && showMetrics) const SizedBox(height: 18),
              if (showMetrics)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 330 ? 3 : 2;
                    const spacing = 8.0;
                    final tileWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List.generate(
                        6,
                        (_) => _SkeletonBox(
                          height: 82,
                          width: tileWidth,
                          radius: 17,
                          color: fill,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.color,
    this.width = double.infinity,
    this.radius = 10,
  });

  final double height;
  final double width;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
