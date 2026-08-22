import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/feature/tenant/data/datasource/tenant_remote_data_source.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository_impl.dart';
import 'package:property/feature/tenant/presentation/provider/tenant_provider.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_ambient_background.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_card.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_empty_view.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_error_banner.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_error_view.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_header.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_loading_view.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_overview_card.dart';
import 'package:property/feature/tenant/presentation/widgets/tenant_section_header.dart';

class TenantRoutePage extends StatelessWidget {
  const TenantRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TenantProvider(
        TenantRepositoryImpl(BaseClientTenantRemoteDataSource(context)),
      ),
      child: const TenantScreen(),
    );
  }
}

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<TenantProvider>();
      final hasNotStarted =
          provider.page == null &&
          !provider.isInitialLoading &&
          provider.errorMessage == null;
      if (hasNotStarted) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<TenantProvider>();
    final page = provider.page;
    final error = provider.errorMessage?.trim();
    final hasError = error != null && error.isNotEmpty;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 700 ? 24.w : 18.w;
    final accents = [colors.secondary, colors.primary, colors.tertiary];

    Future<void> reload() {
      return page == null ? provider.load() : provider.refresh();
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const TenantAmbientBackground(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerLow,
              child: CustomScrollView(
                key: const ValueKey('tenant-scroll-view'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                      child: _CenteredContent(
                        child: TenantHeader(
                          onBack: () => Navigator.of(context).maybePop(),
                          onAdd: () => Navigator.of(
                            context,
                          ).pushNamed(AppRouteName.addTenant),
                        ),
                      ),
                    ),
                  ),
                  if (page == null && provider.isInitialLoading)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        34.h,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: _CenteredContent(child: TenantLoadingView()),
                      ),
                    )
                  else if (page == null && hasError)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        34.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _CenteredContent(
                          child: TenantErrorView(
                            message: error,
                            onRetry: reload,
                          ),
                        ),
                      ),
                    )
                  else if (page == null)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: _CenteredContent(child: TenantLoadingView()),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _CenteredContent(
                          child: Column(
                            children: [
                              if (hasError) ...[
                                TenantErrorBanner(
                                  message: error,
                                  onRetry: reload,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              TenantOverviewCard(page: page),
                              SizedBox(height: 25.h),
                              TenantSectionHeader(
                                count: page.tenants.length,
                                isRefreshing: provider.isRefreshing,
                              ),
                              SizedBox(height: 11.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (page.tenants.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          34.h,
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: _CenteredContent(child: TenantEmptyView()),
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
                        sliver: SliverList.separated(
                          itemCount: page.tenants.length,
                          separatorBuilder: (_, _) => SizedBox(height: 13.h),
                          itemBuilder: (context, index) => _CenteredContent(
                            child: TenantCard(
                              tenant: page.tenants[index],
                              accent: accents[index % accents.length],
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
