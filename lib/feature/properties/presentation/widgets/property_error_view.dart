import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyErrorView extends StatelessWidget {
  const PropertyErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      key: const ValueKey('property-error-view'),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 62.r,
            height: 62.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.domain_disabled_rounded,
              size: 29.r,
              color: colors.error,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'The portfolio is out of reach',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: 18.h),
          FilledButton.icon(
            key: const ValueKey('property-retry-button'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
