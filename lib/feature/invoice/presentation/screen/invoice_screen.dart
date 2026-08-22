import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:property/feature/invoice/data/datasource/invoice_remote_data_source.dart';
import 'package:property/feature/invoice/data/model/invoice_model.dart';
import 'package:property/feature/invoice/data/model/invoice_page_model.dart';
import 'package:property/feature/invoice/data/repository/invoice_repository_impl.dart';
import 'package:property/feature/invoice/presentation/provider/invoice_provider.dart';

class InvoiceRoutePage extends StatelessWidget {
  const InvoiceRoutePage({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => InvoiceProvider(
      InvoiceRepositoryImpl(BaseClientInvoiceRemoteDataSource(context)),
    ),
    child: const InvoiceScreen(),
  );
}

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<InvoiceProvider>();
      if (provider.page == null &&
          !provider.isInitialLoading &&
          provider.errorMessage == null) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<InvoiceProvider>();
    final page = provider.page;
    final error = provider.errorMessage?.trim();
    final hasError = error != null && error.isNotEmpty;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 700
        ? 24.w
        : 18.w;

    Future<void> reload() =>
        page == null ? provider.load() : provider.refresh();

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reload,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerLow,
              child: CustomScrollView(
                key: const ValueKey('invoice-scroll-view'),
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
                        child: _Header(
                          onBack: () => Navigator.of(context).maybePop(),
                          onAdd: _showAddComingSoon,
                        ),
                      ),
                    ),
                  ),
                  if (page == null)
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
                              ? _MessageCard(
                                  icon: Icons.cloud_off_rounded,
                                  title: 'Invoices are out of reach',
                                  message: error,
                                  action: TextButton.icon(
                                    onPressed: reload,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Try again'),
                                  ),
                                )
                              : const _LoadingView(),
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _Centered(
                          child: Column(
                            children: [
                              if (hasError) ...[
                                _ErrorBanner(message: error, onRetry: reload),
                                SizedBox(height: 12.h),
                              ],
                              _InvoiceOverview(page: page),
                              SizedBox(height: 25.h),
                              _SectionHeader(
                                count: page.invoices.length,
                                refreshing: provider.isRefreshing,
                              ),
                              SizedBox(height: 11.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (page.invoices.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          34.h,
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: _Centered(
                            child: _MessageCard(
                              icon: Icons.receipt_long_rounded,
                              title: 'No invoices yet',
                              message:
                                  'New invoices will appear here once they are issued.',
                            ),
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
                          itemCount: page.invoices.length,
                          separatorBuilder: (_, _) => SizedBox(height: 13.h),
                          itemBuilder: (context, index) => _Centered(
                            child: _InvoiceCard(
                              invoice: page.invoices[index],
                              accent: [
                                colors.tertiary,
                                colors.primary,
                                colors.secondary,
                              ][index % 3],
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
          content: Text('Creating an invoice is coming next.'),
        ),
      );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        _RoundButton(
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
                'Invoices',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                'Billing & payment history',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _RoundButton(
          key: const ValueKey('invoice-add-button'),
          tooltip: 'Create invoice',
          icon: Icons.add_rounded,
          filled: true,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
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
            child: Icon(
              icon,
              size: 21.r,
              color: filled ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceOverview extends StatelessWidget {
  const _InvoiceOverview({required this.page});

  final InvoicePageModel page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = page.totalInvoiced <= 0
        ? 0.0
        : (page.totalCollected / page.totalInvoiced).clamp(0.0, 1.0);
    return Container(
      key: const ValueKey('invoice-overview-card'),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.secondary, 0.66)!,
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
              Icon(
                Icons.account_balance_wallet_rounded,
                color: colors.onPrimary,
                size: 22.r,
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  'Collection overview',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              color: colors.onPrimary,
              backgroundColor: colors.onPrimary.withValues(alpha: 0.18),
            ),
          ),
          SizedBox(height: 17.h),
          Row(
            children: [
              Expanded(
                child: _OverviewMetric(
                  label: 'Invoiced',
                  value: _moneyValue(page.currency, page.totalInvoiced),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'Collected',
                  value: _moneyValue(page.currency, page.totalCollected),
                ),
              ),
              const _MetricDivider(),
              Expanded(
                child: _OverviewMetric(
                  label: 'Outstanding',
                  value: _moneyValue(page.currency, page.totalOutstanding),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
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
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34.h,
    margin: EdgeInsets.symmetric(horizontal: 8.w),
    color: Colors.white.withValues(alpha: 0.18),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count, required this.refreshing});

  final int count;
  final bool refreshing;

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
          'Invoice ledger',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(99.r),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (refreshing) ...[
          const Spacer(),
          SizedBox.square(
            dimension: 16.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.accent});

  final InvoiceModel invoice;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      key: ValueKey('invoice-card-${invoice.id}'),
      color: colors.surfaceContainerLow.withValues(alpha: 0.9),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.r),
        topRight: Radius.circular(10.r),
        bottomLeft: Radius.circular(10.r),
        bottomRight: Radius.circular(24.r),
      ),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(10.r),
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(10.r),
              bottomLeft: Radius.circular(10.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43.r,
                    height: 43.r,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: accent,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.displayNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          invoice.lease.unitName.isEmpty
                              ? 'Lease #${invoice.leaseId}'
                              : invoice.lease.unitName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: invoice.status),
                ],
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: _CardMetric(
                      label: 'Balance due',
                      value: _money(invoice.currency, invoice.balanceDue),
                    ),
                  ),
                  Expanded(
                    child: _CardMetric(
                      label: 'Due date',
                      value: _date(invoice.dueDate),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('invoice-details-${invoice.id}'),
                    tooltip: 'Invoice details',
                    onPressed: () => _showDetails(context),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: accent,
                  ),
                ],
              ),
              SizedBox(height: 9.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99.r),
                child: LinearProgressIndicator(
                  value: invoice.paidProgress,
                  minHeight: 5.h,
                  color: accent,
                  backgroundColor: accent.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvoiceDetailsSheet(invoice: invoice, accent: accent),
    );
  }
}

class _CardMetric extends StatelessWidget {
  const _CardMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    final color = normalized == 'paid'
        ? const Color(0xFF16A34A)
        : normalized == 'overdue'
        ? colors.error
        : colors.tertiary;
    final label = status.isEmpty ? 'Pending' : _titleCase(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InvoiceDetailsSheet extends StatelessWidget {
  const _InvoiceDetailsSheet({required this.invoice, required this.accent});

  final InvoiceModel invoice;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DraggableScrollableSheet(
      key: ValueKey('invoice-details-sheet-${invoice.id}'),
      initialChildSize: 0.76,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.displayNumber,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        invoice.lease.unitName.isEmpty
                            ? 'Lease #${invoice.leaseId}'
                            : invoice.lease.unitName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: ValueKey('invoice-details-close-${invoice.id}'),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _DetailMetric(
                      label: 'Total',
                      value: _money(invoice.currency, invoice.totalAmount),
                    ),
                  ),
                  Expanded(
                    child: _DetailMetric(
                      label: 'Paid',
                      value: _money(invoice.currency, invoice.amountPaid),
                    ),
                  ),
                  Expanded(
                    child: _DetailMetric(
                      label: 'Balance',
                      value: _money(invoice.currency, invoice.balanceDue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _DetailRow(
              label: 'Billing period',
              value:
                  '${_date(invoice.periodStart)} – ${_date(invoice.periodEnd)}',
            ),
            _DetailRow(label: 'Issued', value: _date(invoice.issueDate)),
            _DetailRow(label: 'Due', value: _date(invoice.dueDate)),
            _DetailRow(label: 'Tenant ID', value: '#${invoice.lease.tenantId}'),
            _DetailRow(
              label: 'Property ID',
              value: '#${invoice.lease.propertyId}',
            ),
            SizedBox(height: 18.h),
            _SheetTitle(title: 'Line items', count: invoice.items.length),
            SizedBox(height: 8.h),
            if (invoice.items.isEmpty)
              const _InlineEmpty(message: 'No line items were supplied.')
            else
              ...invoice.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: accent.withValues(alpha: 0.12),
                    foregroundColor: accent,
                    child: const Icon(Icons.sell_rounded),
                  ),
                  title: Text(
                    item.description.isEmpty
                        ? _titleCase(item.type)
                        : item.description,
                  ),
                  subtitle: item.type.isEmpty
                      ? null
                      : Text(_titleCase(item.type)),
                  trailing: Text(
                    _money(invoice.currency, item.amount),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 18.h),
            _SheetTitle(title: 'Payments', count: invoice.payments.length),
            SizedBox(height: 8.h),
            if (invoice.payments.isEmpty)
              const _InlineEmpty(message: 'No payments have been recorded.')
            else
              ...invoice.payments.map(
                (payment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colors.secondaryContainer,
                    foregroundColor: colors.onSecondaryContainer,
                    child: const Icon(Icons.payments_rounded),
                  ),
                  title: Text(
                    _money(
                      payment.currency.isEmpty
                          ? invoice.currency
                          : payment.currency,
                      payment.amount,
                    ),
                  ),
                  subtitle: Text(
                    [payment.method, _date(payment.paidOn)]
                        .where((part) => part.isNotEmpty && part != '—')
                        .join(' • '),
                  ),
                  trailing: payment.reference.isEmpty
                      ? null
                      : Text(payment.reference),
                ),
              ),
            if (invoice.notes.isNotEmpty) ...[
              SizedBox(height: 18.h),
              const _SheetTitle(title: 'Notes'),
              SizedBox(height: 8.h),
              Text(invoice.notes, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title, this.count});
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      if (count != null) ...[
        SizedBox(width: 6.w),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ],
  );
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.r),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Text(message),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
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

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

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
          if (action != null) ...[SizedBox(height: 8.h), action!],
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (index) => Container(
        height: index == 0 ? 142.h : 126.h,
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

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

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
              color: colors.tertiary,
              top: 330.h,
              left: -125.w,
              size: 190.r,
            ),
            _Halo(
              color: colors.secondary,
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

String _money(String currency, String value) {
  final parsed = double.tryParse(value);
  return _moneyValue(currency, parsed ?? 0);
}

String _moneyValue(String currency, double value) {
  final amount = NumberFormat('#,##0.##').format(value);
  return currency.isEmpty ? amount : '$currency $amount';
}

String _date(DateTime? value) =>
    value == null ? '—' : DateFormat('d MMM yyyy').format(value);

String _titleCase(String value) => value
    .trim()
    .replaceAll('_', ' ')
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
    .join(' ');
