import 'package:flutter/material.dart';

class DashboardErrorBanner extends StatelessWidget {
  const DashboardErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: colors.onErrorContainer,
              size: 19,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Retry',
              visualDensity: VisualDensity.compact,
              color: colors.onErrorContainer,
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}
