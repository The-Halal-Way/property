import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:property/feature/dashboard/presentation/widgets/collection_progress_ring.dart';

class FinancialOverviewCard extends StatelessWidget {
  const FinancialOverviewCard({
    super.key,
    required this.expected,
    required this.collected,
    required this.outstanding,
    required this.collectionRate,
  });

  final num expected;
  final num collected;
  final num outstanding;
  final num collectionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final gradientStart = Color.lerp(
      colors.primary,
      Colors.black,
      isDark ? 0.38 : 0.24,
    )!;
    final gradientEnd = Color.lerp(
      colors.tertiary,
      Colors.black,
      isDark ? 0.50 : 0.30,
    )!;

    return Semantics(
      container: true,
      label:
          'Financial overview. Collected ${_formatNumber(collected)}. '
          'Expected ${_formatNumber(expected)}. '
          'Outstanding ${_formatNumber(outstanding)}.',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: isDark ? 0.16 : 0.20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(26),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -48,
                    right: -30,
                    child: _GlowOrb(
                      size: 142,
                      color: colors.secondary.withValues(alpha: 0.16),
                    ),
                  ),
                  Positioned(
                    bottom: -56,
                    left: 72,
                    child: _GlowOrb(
                      size: 128,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'COLLECTED',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatNumber(collected),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'of ${_formatNumber(expected)} expected',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.74,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            CollectionProgressRing(
                              value: collectionRate.toDouble(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _FinancialValue(
                                label: 'Expected',
                                value: _formatNumber(expected),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FinancialValue(
                                label: 'Outstanding',
                                value: _formatNumber(outstanding),
                              ),
                            ),
                          ],
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

  static String _formatNumber(num value) {
    if (value.abs() < 1000) {
      return NumberFormat('#,##0.##').format(value);
    }
    return NumberFormat.compact().format(value);
  }
}

class _FinancialValue extends StatelessWidget {
  const _FinancialValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
