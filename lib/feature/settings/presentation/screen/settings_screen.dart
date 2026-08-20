import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/config/theme/theme_provider.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = context.read<AuthRepository>().currentUser;
    final email = user?.email?.trim() ?? '';
    final displayName = user?.displayName?.trim();
    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : _nameFromEmail(email);

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
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 34.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _ScreenTitle(),
                            SizedBox(height: 22.h),
                            _AccountHero(name: name, email: email),
                            SizedBox(height: 28.h),
                            const _SectionLead(
                              eyebrow: 'ATMOSPHERE',
                              title: 'Choose your mood',
                              description:
                                  'Tune the space around your work, not just the brightness.',
                            ),
                            SizedBox(height: 13.h),
                            const _AppearanceStudio(),
                            SizedBox(height: 30.h),
                            const _SectionLead(
                              eyebrow: 'SESSION',
                              title: 'Leave on your terms',
                              description:
                                  'End this session securely whenever you need a reset.',
                            ),
                            SizedBox(height: 13.h),
                            const _SignOutAction(),
                            SizedBox(height: 28.h),
                            Text(
                              'PROPERTY  /  PERSONAL SPACE',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.64,
                                ),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) return 'Your account';
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'Your account' : localPart;
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
            _Halo(color: primary, size: 270.r, top: -145.h, right: -118.w),
            _Halo(color: secondary, size: 190.r, top: 248.h, left: -118.w),
            _Halo(color: tertiary, size: 160.r, bottom: 42.h, right: -108.w),
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
          color: color.withValues(alpha: 0.065),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.17),
              blurRadius: 82.r,
              spreadRadius: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONAL CONTROL',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.45,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Settings with\na point of view.',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.04,
                  letterSpacing: -0.55,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 47.r,
          height: 47.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.74),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(7.r),
              bottomLeft: Radius.circular(7.r),
              bottomRight: Radius.circular(18.r),
            ),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.58),
            ),
          ),
          child: Text(
            'P/',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = Color.lerp(colors.secondary, colors.tertiary, 0.34)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, Color.lerp(colors.primary, accent, 0.56)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.28),
            blurRadius: 26.r,
            offset: Offset(0, 13.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100.r,
            right: -74.r,
            child: _HeroOrbit(color: colors.onPrimary.withValues(alpha: 0.13)),
          ),
          Positioned(
            bottom: -111.r,
            right: 32.r,
            child: _HeroOrbit(
              color: colors.onPrimary.withValues(alpha: 0.11),
              size: 168.r,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SIGNED IN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.25,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99.r),
                      border: Border.all(
                        color: colors.onPrimary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.secondary.withValues(alpha: 0.8),
                                blurRadius: 8.r,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'ACTIVE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.sp,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 23.h),
              Row(
                children: [
                  _Monogram(name: name),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          email.isEmpty ? 'Your private space' : email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.76),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              Container(
                height: 1,
                color: colors.onPrimary.withValues(alpha: 0.16),
              ),
              SizedBox(height: 12.h),
              Text(
                'YOUR SPACE, YOUR SIGNAL.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroOrbit extends StatelessWidget {
  const _HeroOrbit({required this.color, this.size = 196});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 24.r),
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 61.r,
      height: 61.r,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: colors.onPrimary.withValues(alpha: 0.3)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.onPrimary.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _initials(name),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'P';

    final first = String.fromCharCode(parts.first.runes.first);
    if (parts.length == 1) return first.toUpperCase();
    final last = String.fromCharCode(parts.last.runes.first);
    return '$first$last'.toUpperCase();
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.secondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.35,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _AppearanceStudio extends StatelessWidget {
  const _AppearanceStudio();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.82),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22.r),
          topRight: Radius.circular(9.r),
          bottomLeft: Radius.circular(9.r),
          bottomRight: Radius.circular(22.r),
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.045),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _AppearanceOption(
              label: 'System',
              icon: Icons.settings_suggest_rounded,
              mode: ThemeMode.system,
              selected: themeProvider.themeMode == ThemeMode.system,
              preview: [colors.primary, colors.secondary],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _AppearanceOption(
              label: 'Light',
              icon: Icons.wb_sunny_outlined,
              mode: ThemeMode.light,
              selected: themeProvider.themeMode == ThemeMode.light,
              preview: [colors.surfaceBright, colors.primaryContainer],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _AppearanceOption(
              label: 'Night',
              icon: Icons.nights_stay_outlined,
              mode: ThemeMode.dark,
              selected: themeProvider.themeMode == ThemeMode.dark,
              preview: [colors.inverseSurface, colors.primary],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selected,
    required this.preview,
  });

  final String label;
  final IconData icon;
  final ThemeMode mode;
  final bool selected;
  final List<Color> preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label appearance',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<ThemeProvider>().setThemeMode(mode),
          borderRadius: BorderRadius.circular(14.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.11)
                  : colors.surfaceContainerLowest.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected
                    ? colors.primary.withValues(alpha: 0.8)
                    : colors.outlineVariant.withValues(alpha: 0.45),
                width: selected ? 1.35 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: preview,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icon,
                          color: mode == ThemeMode.light
                              ? colors.onPrimaryContainer
                              : colors.onPrimary,
                          size: 18.r,
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 5.r,
                          right: 5.r,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: BoxDecoration(
                              color: colors.onPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: colors.primary,
                              size: 10.r,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutAction extends StatelessWidget {
  const _SignOutAction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.errorContainer.withValues(alpha: 0.38),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(17.r),
            topRight: Radius.circular(7.r),
            bottomLeft: Radius.circular(7.r),
            bottomRight: Radius.circular(17.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: provider.isSigningOut
                ? null
                : () => _confirmSignOut(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.18),
                      ),
                    ),
                    child: provider.isSigningOut
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.error,
                            ),
                          )
                        : Icon(
                            Icons.logout_rounded,
                            color: colors.error,
                            size: 20.r,
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.isSigningOut ? 'Signing out…' : 'Sign out',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Close this session on this device',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onErrorContainer.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: colors.error,
                    size: 19.r,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (provider.errorMessage case final error?) ...[
          SizedBox(height: 8.h),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      await context.read<SettingsProvider>().signOut();
    }
  }
}
