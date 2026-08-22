import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:property/feature/tenant/data/model/tenant_lease_model.dart';

class TenantLeaseSection extends StatelessWidget {
  const TenantLeaseSection({super.key, required this.leases});

  final List<TenantLeaseModel> leases;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (leases.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          'No lease records are attached to this tenant.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 10.sp,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < leases.length; index++) ...[
          _LeaseTile(lease: leases[index]),
          if (index != leases.length - 1) SizedBox(height: 9.h),
        ],
      ],
    );
  }
}

class _LeaseTile extends StatelessWidget {
  const _LeaseTile({required this.lease});

  final TenantLeaseModel lease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = lease.isActive
        ? const Color(0xFF10B981)
        : colors.tertiary;
    final unitName = lease.unitName.isEmpty
        ? 'Unit #${lease.unitId}'
        : lease.unitName;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surfaceContainerHighest.withValues(alpha: 0.42),
            colors.surfaceContainerLow.withValues(alpha: 0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.door_front_door_rounded,
                  size: 17.r,
                  color: colors.secondary,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unitName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      lease.propertyId > 0
                          ? 'Property #${lease.propertyId}'
                          : 'Property not specified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  _titleCase(lease.status.isEmpty ? 'Unknown' : lease.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Row(
            children: [
              Expanded(
                child: _LeaseMetric(label: 'Rent', value: _rentLabel(lease)),
              ),
              Expanded(
                child: _LeaseMetric(
                  label: 'Billing',
                  value: _titleCase(
                    lease.billingFrequency.isEmpty
                        ? 'Not set'
                        : lease.billingFrequency,
                  ),
                ),
              ),
              Expanded(
                child: _LeaseMetric(
                  label: 'Due',
                  value: lease.dueDay > 0 ? 'Day ${lease.dueDay}' : 'Not set',
                ),
              ),
            ],
          ),
          if (lease.startDate != null || lease.endDate != null) ...[
            SizedBox(height: 10.h),
            Text(
              '${_dateLabel(lease.startDate)}  →  ${_dateLabel(lease.endDate)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _rentLabel(TenantLeaseModel lease) {
    final amount = lease.rentAmount.isEmpty ? 'Not set' : lease.rentAmount;
    return lease.currency.isEmpty ? amount : '${lease.currency} $amount';
  }

  String _dateLabel(DateTime? date) {
    return date == null ? 'Open ended' : DateFormat('dd MMM yyyy').format(date);
  }

  String _titleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _LeaseMetric extends StatelessWidget {
  const _LeaseMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 8.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurface,
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
