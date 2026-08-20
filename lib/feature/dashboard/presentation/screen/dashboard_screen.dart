import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/dashboard/presentation/provider/dashboard_provider.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_error_banner.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_error_view.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_loading_view.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_metrics_grid.dart';
import 'package:property/feature/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:property/feature/dashboard/presentation/widgets/financial_overview_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onQuickActionSelected});

  final ValueChanged<String>? onQuickActionSelected;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<DashboardProvider>();
      final hasNotStarted =
          provider.data == null &&
          !provider.isInitialLoading &&
          provider.errorMessage == null;
      if (hasNotStarted) provider.load(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<DashboardProvider>();
    final data = provider.data;
    final errorMessage = provider.errorMessage?.trim();
    final hasError = errorMessage != null && errorMessage.isNotEmpty;

    Future<void> reload() {
      return data == null ? provider.load(context) : provider.refresh(context);
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 700 ? 24.w : 18.w;

    return ColoredBox(
      color: colors.surface,
      child: Stack(
        children: [
          _AmbientBackground(
            primary: colors.primary,
            secondary: colors.secondary,
            tertiary: colors.tertiary,
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16.h,
                      horizontalPadding,
                      34.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DashboardHeader(
                                isRefreshing: provider.isRefreshing,
                                onRefresh: reload,
                              ),
                              if (provider.isRefreshing) ...[
                                SizedBox(height: 12.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: const LinearProgressIndicator(
                                    minHeight: 3,
                                  ),
                                ),
                              ],
                              SizedBox(height: 18.h),
                              if (data == null && provider.isInitialLoading)
                                const DashboardLoadingView(showMetrics: false)
                              else if (data == null && hasError)
                                DashboardErrorView(
                                  message: errorMessage,
                                  onRetry: reload,
                                )
                              else if (data == null)
                                const DashboardLoadingView(showMetrics: false)
                              else ...[
                                if (hasError) ...[
                                  DashboardErrorBanner(
                                    message: errorMessage,
                                    onRetry: reload,
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                                FinancialOverviewCard(
                                  expected: data.financials.expected,
                                  collected: data.financials.collected,
                                  outstanding: data.financials.outstanding,
                                  collectionRate:
                                      data.financials.collectionRate,
                                ),
                              ],
                              SizedBox(height: 22.h),
                              const _SectionTitle(title: 'Quick access'),
                              SizedBox(height: 10.h),
                              DashboardQuickActions(
                                onSelected: _handleQuickAction,
                              ),
                              if (!hasError || data != null) ...[
                                SizedBox(height: 24.h),
                                const _SectionTitle(title: 'Portfolio'),
                                SizedBox(height: 10.h),
                                if (data == null)
                                  const DashboardLoadingView(
                                    showOverview: false,
                                  )
                                else
                                  DashboardMetricsGrid(
                                    properties: data.stats.properties,
                                    units: data.stats.units,
                                    occupied: data.stats.occupied,
                                    vacant: data.stats.vacant,
                                    tenants: data.stats.tenants,
                                    activeLeases: data.stats.activeLeases,
                                  ),
                              ],
                            ],
                          ),
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

  void _handleQuickAction(String label) {
    final onSelected = widget.onQuickActionSelected;
    if (onSelected != null) {
      onSelected(label);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('$label workspace is not available yet.'),
        ),
      );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 5.r,
          height: 18.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _Halo(color: primary, size: 280.r, top: -154.h, right: -116.w),
            _Halo(color: secondary, size: 196.r, top: 322.h, left: -128.w),
            _Halo(color: tertiary, size: 174.r, bottom: 86.h, right: -112.w),
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
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.16),
              blurRadius: 84.r,
              spreadRadius: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
