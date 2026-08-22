import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/report/data/datasource/report_remote_data_source.dart';
import 'package:property/feature/report/data/model/report_model.dart';
import 'package:property/feature/report/data/repository/report_repository_impl.dart';
import 'package:property/feature/report/presentation/provider/report_provider.dart';

class ReportRoutePage extends StatelessWidget {
  const ReportRoutePage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => ReportProvider(
      ReportRepositoryImpl(BaseClientReportRemoteDataSource(context)),
    ),
    child: const ReportScreen(),
  );
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ReportProvider>();
      if (provider.data == null &&
          !provider.isInitialLoading &&
          provider.errorMessage == null) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ReportProvider>();
    final report = provider.data;
    final error = provider.errorMessage?.trim();
    final hasError = error != null && error.isNotEmpty;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 700
        ? 24.w
        : 18.w;

    Future<void> reload() =>
        report == null ? provider.load() : provider.refresh();

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const _ReportAmbientBackground(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerLow,
              child: CustomScrollView(
                key: const ValueKey('report-scroll-view'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14.h,
                      horizontalPadding,
                      18.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _Centered(
                        child: _ReportHeader(
                          refreshing: provider.isRefreshing,
                          onBack: () => Navigator.of(context).maybePop(),
                          onRefresh: reload,
                        ),
                      ),
                    ),
                  ),
                  if (report == null)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        34.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _Centered(
                          child: hasError
                              ? _ReportMessage(
                                  icon: Icons.cloud_off_rounded,
                                  title: 'Report is out of reach',
                                  message: error,
                                  onRetry: reload,
                                )
                              : const _ReportLoadingView(),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        38.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _Centered(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (hasError) ...[
                                _ReportErrorBanner(
                                  message: error,
                                  onRetry: reload,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              _CollectionsOverview(report: report),
                              SizedBox(height: 24.h),
                              const _SectionTitle(
                                title: 'Receivables aging',
                                subtitle: 'Outstanding balance by due date',
                              ),
                              SizedBox(height: 11.h),
                              _AgingCard(report: report),
                              SizedBox(height: 24.h),
                              const _SectionTitle(
                                title: 'Portfolio health',
                                subtitle: 'A quick read on collections',
                              ),
                              SizedBox(height: 11.h),
                              _HealthCard(report: report),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.refreshing,
    required this.onBack,
    required this.onRefresh,
  });

  final bool refreshing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        _HeaderButton(
          tooltip: 'Back',
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                'Collections & receivables',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _HeaderButton(
          key: const ValueKey('report-refresh-button'),
          tooltip: 'Refresh report',
          icon: Icons.refresh_rounded,
          onPressed: refreshing ? null : onRefresh,
          loading: refreshing,
          filled: true,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? colors.primary : colors.surfaceContainerLow,
        shape: CircleBorder(
          side: BorderSide(
            color: filled
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 43.r,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 18.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 21.r,
                      color: filled ? colors.onPrimary : colors.onSurface,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionsOverview extends StatelessWidget {
  const _CollectionsOverview({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rate = report.collectionRate;
    return Container(
      key: const ValueKey('report-overview-card'),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.secondary, 0.7)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(11.r),
          bottomLeft: Radius.circular(11.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.query_stats_rounded,
                  color: colors.onPrimary,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection performance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${(rate * 100).round()}% of invoiced value collected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 17.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6.h,
              color: colors.onPrimary,
              backgroundColor: colors.onPrimary.withValues(alpha: 0.18),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Invoiced',
                  value: _money(report.currency, report.collections.invoiced),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'Collected',
                  value: _money(report.currency, report.collections.collected),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'Outstanding',
                  value: _money(
                    report.currency,
                    report.collections.outstanding,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12.sp,
        ),
      ),
      SizedBox(height: 3.h),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 9.sp,
        ),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 35.h,
    margin: EdgeInsets.symmetric(horizontal: 8.w),
    color: Colors.white.withValues(alpha: 0.18),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5.r,
          height: 36.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgingCard extends StatelessWidget {
  const _AgingCard({required this.report});
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final aging = report.aging;
    final buckets = [
      ('Not due', aging.notDue, colors.primary, Icons.event_available_rounded),
      ('1–30 days', aging.d1To30, colors.secondary, Icons.schedule_rounded),
      ('31–60 days', aging.d31To60, colors.tertiary, Icons.history_rounded),
      (
        '61–90 days',
        aging.d61To90,
        const Color(0xFFF97316),
        Icons.warning_amber_rounded,
      ),
      ('90+ days', aging.d90Plus, colors.error, Icons.report_problem_rounded),
    ];
    final resolvedTotal = aging.total > 0
        ? aging.total
        : buckets.fold<double>(0, (sum, bucket) => sum + bucket.$2);
    return Container(
      key: const ValueKey('report-aging-card'),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.58),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < buckets.length; index++) ...[
            _AgingRow(
              key: ValueKey('report-aging-row-$index'),
              label: buckets[index].$1,
              value: buckets[index].$2,
              total: resolvedTotal,
              currency: report.currency,
              color: buckets[index].$3,
              icon: buckets[index].$4,
            ),
            if (index != buckets.length - 1)
              Divider(height: 19.h, color: colors.outlineVariant),
          ],
          Divider(height: 22.h, color: colors.outline),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total receivables',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  _money(report.currency, aging.total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgingRow extends StatelessWidget {
  const _AgingRow({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.currency,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final double total;
  final String currency;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total <= 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Row(
      children: [
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 20.r),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _money(currency, value),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4.h,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.report});
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue =
        report.aging.d1To30 +
        report.aging.d31To60 +
        report.aging.d61To90 +
        report.aging.d90Plus;
    final riskRate = report.aging.total <= 0
        ? 0.0
        : (overdue / report.aging.total).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 520;
        final cards = [
          _HealthMetric(
            icon: Icons.done_all_rounded,
            label: 'Collection rate',
            value: '${(report.collectionRate * 100).round()}%',
            color: colors.primary,
          ),
          _HealthMetric(
            icon: Icons.timelapse_rounded,
            label: 'Overdue share',
            value: '${(riskRate * 100).round()}%',
            color: riskRate > 0.5 ? colors.error : colors.tertiary,
          ),
        ];
        return Container(
          key: const ValueKey('report-health-card'),
          padding: EdgeInsets.all(13.r),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: horizontal
              ? Row(
                  children: [
                    Expanded(child: cards[0]),
                    SizedBox(width: 10.w),
                    Expanded(child: cards[1]),
                  ],
                )
              : Column(
                  children: [
                    cards[0],
                    SizedBox(height: 10.h),
                    cards[1],
                  ],
                ),
        );
      },
    );
  }
}

class _HealthMetric extends StatelessWidget {
  const _HealthMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(13.r),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 22.r),
        SizedBox(width: 9.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _ReportErrorBanner extends StatelessWidget {
  const _ReportErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 7.h, 7.w, 7.h),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.onErrorContainer),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ReportMessage extends StatelessWidget {
  const _ReportMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38.r, color: colors.primary),
          SizedBox(height: 10.h),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ReportLoadingView extends StatelessWidget {
  const _ReportLoadingView();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (index) => Container(
        height: index == 0 ? 156.h : 190.h,
        margin: EdgeInsets.only(bottom: 13.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    ),
  );
}

class _ReportAmbientBackground extends StatelessWidget {
  const _ReportAmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _Halo(
              color: colors.primary,
              top: -150.h,
              right: -110.w,
              size: 270.r,
            ),
            _Halo(
              color: colors.secondary,
              top: 330.h,
              left: -125.w,
              size: 190.r,
            ),
            _Halo(
              color: colors.tertiary,
              bottom: 60.h,
              right: -105.w,
              size: 165.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
  final Color color;
  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    right: right,
    bottom: bottom,
    left: left,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.055),
      ),
    ),
  );
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

String _money(String currency, double value) {
  final amount = NumberFormat('#,##0.##').format(value);
  return currency.isEmpty ? amount : '$currency $amount';
}
