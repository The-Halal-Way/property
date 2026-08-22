import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/employee/data/datasource/employee_remote_data_source.dart';
import 'package:property/feature/employee/data/repository/employee_repository_impl.dart';
import 'package:property/feature/employee/presentation/provider/employee_provider.dart';
import 'package:property/feature/employee/presentation/widgets/employee_ambient_background.dart';
import 'package:property/feature/employee/presentation/widgets/employee_card.dart';
import 'package:property/feature/employee/presentation/widgets/employee_empty_view.dart';
import 'package:property/feature/employee/presentation/widgets/employee_error_banner.dart';
import 'package:property/feature/employee/presentation/widgets/employee_error_view.dart';
import 'package:property/feature/employee/presentation/widgets/employee_header.dart';
import 'package:property/feature/employee/presentation/widgets/employee_loading_view.dart';
import 'package:property/feature/employee/presentation/widgets/employee_overview_card.dart';
import 'package:property/feature/employee/presentation/widgets/employee_section_header.dart';

class EmployeeRoutePage extends StatelessWidget {
  const EmployeeRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeProvider(
        EmployeeRepositoryImpl(BaseClientEmployeeRemoteDataSource(context)),
      ),
      child: const EmployeeScreen(),
    );
  }
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<EmployeeProvider>();
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
    final provider = context.watch<EmployeeProvider>();
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
          const EmployeeAmbientBackground(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerLow,
              child: CustomScrollView(
                key: const ValueKey('employee-scroll-view'),
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
                      child: _CenteredEmployeeContent(
                        child: EmployeeHeader(
                          onBack: () => Navigator.of(context).maybePop(),
                          onAdd: _showAddComingSoon,
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
                        child: _CenteredEmployeeContent(
                          child: EmployeeLoadingView(),
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
                        child: _CenteredEmployeeContent(
                          child: EmployeeErrorView(
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
                        child: _CenteredEmployeeContent(
                          child: EmployeeLoadingView(),
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _CenteredEmployeeContent(
                          child: Column(
                            children: [
                              if (hasError) ...[
                                EmployeeErrorBanner(
                                  message: error,
                                  onRetry: reload,
                                ),
                                SizedBox(height: 12.h),
                              ],
                              EmployeeOverviewCard(page: page),
                              SizedBox(height: 25.h),
                              EmployeeSectionHeader(
                                count: page.employees.length,
                                isRefreshing: provider.isRefreshing,
                              ),
                              SizedBox(height: 11.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (page.employees.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          34.h,
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: _CenteredEmployeeContent(
                            child: EmployeeEmptyView(),
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
                          itemCount: page.employees.length,
                          separatorBuilder: (_, _) => SizedBox(height: 13.h),
                          itemBuilder: (context, index) =>
                              _CenteredEmployeeContent(
                                child: EmployeeCard(
                                  employee: page.employees[index],
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

  void _showAddComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Adding an employee is coming next.'),
        ),
      );
  }
}

class _CenteredEmployeeContent extends StatelessWidget {
  const _CenteredEmployeeContent({required this.child});

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
