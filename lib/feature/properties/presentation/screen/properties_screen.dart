import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/feature/properties/data/datasource/property_remote_data_source.dart';
import 'package:property/feature/properties/data/repository/property_repository_impl.dart';
import 'package:property/feature/properties/presentation/provider/property_provider.dart';
import 'package:property/feature/properties/presentation/widgets/property_ambient_background.dart';
import 'package:property/feature/properties/presentation/widgets/property_card.dart';
import 'package:property/feature/properties/presentation/widgets/property_empty_view.dart';
import 'package:property/feature/properties/presentation/widgets/property_error_banner.dart';
import 'package:property/feature/properties/presentation/widgets/property_error_view.dart';
import 'package:property/feature/properties/presentation/widgets/property_header.dart';
import 'package:property/feature/properties/presentation/widgets/property_loading_view.dart';
import 'package:property/feature/properties/presentation/widgets/property_overview_card.dart';
import 'package:property/feature/properties/presentation/widgets/property_section_header.dart';

class PropertiesRoutePage extends StatelessWidget {
  const PropertiesRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyProvider(
        PropertyRepositoryImpl(BaseClientPropertyRemoteDataSource(context)),
      ),
      child: const PropertiesScreen(),
    );
  }
}

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<PropertyProvider>();
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
    final provider = context.watch<PropertyProvider>();
    final page = provider.page;
    final error = provider.errorMessage?.trim();
    final hasError = error != null && error.isNotEmpty;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 700 ? 24.w : 18.w;
    final accents = [colors.primary, colors.secondary, colors.tertiary];

    Future<void> reload() {
      return page == null ? provider.load() : provider.refresh();
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const PropertyAmbientBackground(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerLow,
              child: CustomScrollView(
                key: const ValueKey('property-scroll-view'),
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
                      child: _CenteredPropertyContent(
                        child: PropertyHeader(
                          onBack: () => Navigator.of(context).maybePop(),
                          onAdd: () => Navigator.of(
                            context,
                          ).pushNamed(AppRouteName.addProperty),
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
                        child: _CenteredPropertyContent(
                          child: PropertyLoadingView(),
                        ),
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
                        child: _CenteredPropertyContent(
                          child: PropertyErrorView(
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
                        child: _CenteredPropertyContent(
                          child: PropertyLoadingView(),
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _CenteredPropertyContent(
                          child: Column(
                            children: [
                              if (hasError) ...[
                                PropertyErrorBanner(
                                  message: error,
                                  onRetry: reload,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              PropertyOverviewCard(page: page),
                              SizedBox(height: 25.h),
                              PropertySectionHeader(
                                count: page.properties.length,
                                isRefreshing: provider.isRefreshing,
                              ),
                              SizedBox(height: 11.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (page.properties.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          34.h,
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: _CenteredPropertyContent(
                            child: PropertyEmptyView(),
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
                        sliver: SliverList.separated(
                          itemCount: page.properties.length,
                          separatorBuilder: (_, _) => SizedBox(height: 13.h),
                          itemBuilder: (context, index) =>
                              _CenteredPropertyContent(
                                child: PropertyCard(
                                  property: page.properties[index],
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

class _CenteredPropertyContent extends StatelessWidget {
  const _CenteredPropertyContent({required this.child});

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
