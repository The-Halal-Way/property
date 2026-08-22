import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    super.key,
    required this.initials,
    required this.photoUrl,
    required this.accent,
    this.size,
  });

  final String initials;
  final String photoUrl;
  final Color accent;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedSize = size ?? 54.r;

    return Container(
      width: resolvedSize,
      height: resolvedSize,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, colors.primary, 0.5)!],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(8.r),
          bottomLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(17.r),
          topRight: Radius.circular(6.r),
          bottomLeft: Radius.circular(6.r),
          bottomRight: Radius.circular(17.r),
        ),
        child: photoUrl.isEmpty
            ? _Initials(initials: initials, accent: accent)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _Initials(initials: initials, accent: accent),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials, required this.accent});

  final String initials;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
