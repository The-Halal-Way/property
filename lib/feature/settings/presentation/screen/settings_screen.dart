import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/config/router/app_router.dart';
import 'package:property/config/theme/theme_provider.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/presentation/provider/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialAvatarUrl,
  });

  final String? initialName;
  final String? initialEmail;
  final String? initialAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final provider = context.watch<SettingsProvider>();
    final profile = provider.profile;
    final needsAuthUser =
        initialName == null || initialEmail == null || initialAvatarUrl == null;
    final user = needsAuthUser
        ? context.read<AuthRepository>().currentUser
        : null;
    final email = profile?.email.trim().isNotEmpty == true
        ? profile!.email
        : initialEmail ?? user?.email?.trim() ?? '';
    final authName = initialName ?? user?.displayName?.trim() ?? '';
    final name = profile?.name.trim().isNotEmpty == true
        ? profile!.name
        : authName.isNotEmpty
        ? authName
        : _nameFromEmail(email);
    final avatarUrl = profile?.avatarUrl.trim().isNotEmpty == true
        ? profile!.avatarUrl
        : initialAvatarUrl ?? user?.photoURL ?? '';

    return ColoredBox(
      key: const ValueKey('settings-page'),
      color: colors.surface,
      child: Stack(
        children: [
          const _SettingsAmbientBackground(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              key: const ValueKey('settings-scroll-view'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(17.w, 13.h, 17.w, 28.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _CompactSettingsHeader(),
                            SizedBox(height: 13.h),
                            _CompactAccountHero(
                              name: name,
                              email: email,
                              avatarUrl: avatarUrl,
                            ),
                            SizedBox(height: 19.h),
                            const _SettingsSectionLabel(
                              eyebrow: 'ACCOUNT',
                              title: 'Your account',
                            ),
                            SizedBox(height: 8.h),
                            _SettingsGroup(
                              children: [
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-profile-option',
                                  ),
                                  icon: Icons.person_outline_rounded,
                                  title: 'Profile',
                                  subtitle: 'Contact and regional details',
                                  onTap: () => _openAccountSection(
                                    context,
                                    AppRouteName.profileDetails,
                                    provider,
                                  ),
                                ),
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-preferences-option',
                                  ),
                                  icon: Icons.tune_rounded,
                                  title: 'Preferences',
                                  subtitle: 'Currency and display choices',
                                  onTap: () => _openAccountSection(
                                    context,
                                    AppRouteName.preferences,
                                    provider,
                                  ),
                                ),
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-password-option',
                                  ),
                                  icon: Icons.password_rounded,
                                  title: 'Password',
                                  subtitle: 'Prepare a secure password change',
                                  onTap: () => _openAccountSection(
                                    context,
                                    AppRouteName.password,
                                    provider,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 19.h),
                            const _SettingsSectionLabel(
                              eyebrow: 'APPEARANCE',
                              title: 'Theme',
                            ),
                            SizedBox(height: 8.h),
                            const _CompactThemePicker(),
                            SizedBox(height: 19.h),
                            const _SettingsSectionLabel(
                              eyebrow: 'SERVICES & SUPPORT',
                              title: 'Help and legal',
                            ),
                            SizedBox(height: 8.h),
                            _SettingsGroup(
                              children: [
                                _SettingsTile(
                                  key: const ValueKey('settings-help-option'),
                                  icon: Icons.help_outline_rounded,
                                  title: 'Help center',
                                  subtitle: 'Guides and common questions',
                                  onTap: () =>
                                      _showPendingPage(context, 'Help center'),
                                ),
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-privacy-option',
                                  ),
                                  icon: Icons.privacy_tip_outlined,
                                  title: 'Privacy policy',
                                  subtitle: 'How your information is handled',
                                  onTap: () => _showPendingPage(
                                    context,
                                    'Privacy policy',
                                  ),
                                ),
                                _SettingsTile(
                                  key: const ValueKey('settings-terms-option'),
                                  icon: Icons.description_outlined,
                                  title: 'Terms of service',
                                  subtitle: 'Rules for using PropertyApp',
                                  onTap: () => _showPendingPage(
                                    context,
                                    'Terms of service',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 19.h),
                            const _SettingsSectionLabel(
                              eyebrow: 'SESSION & DATA',
                              title: 'Account controls',
                            ),
                            SizedBox(height: 8.h),
                            _SettingsGroup(
                              children: [
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-sign-out-option',
                                  ),
                                  icon: Icons.logout_rounded,
                                  title: provider.isSigningOut
                                      ? 'Signing out…'
                                      : 'Sign out',
                                  subtitle: 'End this session on this device',
                                  isLoading: provider.isSigningOut,
                                  onTap: provider.isSigningOut
                                      ? null
                                      : () => _confirmSignOut(context),
                                ),
                                _SettingsTile(
                                  key: const ValueKey(
                                    'settings-delete-account-option',
                                  ),
                                  icon: Icons.delete_forever_outlined,
                                  title: 'Delete account',
                                  subtitle: 'Permanently remove account data',
                                  destructive: true,
                                  onTap: () => _confirmDeleteAccount(context),
                                ),
                              ],
                            ),
                            if (provider.errorMessage case final error?) ...[
                              SizedBox(height: 8.h),
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.error,
                                ),
                              ),
                            ],
                            SizedBox(height: 17.h),
                            Text(
                              'PROPERTYAPP  /  ACCOUNT CONTROL',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.62,
                                ),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.15,
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

  Future<void> _openAccountSection(
    BuildContext context,
    String route,
    SettingsProvider provider,
  ) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(route, arguments: provider.profile);
    if (result is ProfileModel && context.mounted) {
      provider.applyProfile(result);
    }
  }

  void _showPendingPage(BuildContext context, String page) {
    MyDialog().showComingSoonDialog(context: context, featureName: page);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final approved = await showDialog<bool>(
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
    if (approved == true && context.mounted) {
      await context.read<SettingsProvider>().signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: const Text('Delete account?'),
        content: const Text(
          'This will permanently remove your account and property data once the deletion API is connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (approved == true && context.mounted) {
      MyDialog().showInfoToast(
        title: 'API pending',
        msg: 'Account deletion will be enabled when its API is available.',
        context: context,
      );
    }
  }
}

class _CompactSettingsHeader extends StatelessWidget {
  const _CompactSettingsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONTROL CENTER',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.35,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Icons.settings_rounded,
            color: colors.primary,
            size: 20.r,
          ),
        ),
      ],
    );
  }
}

class _CompactAccountHero extends StatelessWidget {
  const _CompactAccountHero({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('settings-account-hero'),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.secondary, 0.52)!,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(11.r),
          bottomLeft: Radius.circular(11.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.22),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _HeroAvatar(name: name, avatarUrl: avatarUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  email.isEmpty ? 'Your private workspace' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user_outlined,
            color: colors.onPrimary,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Container(
      color: colors.onPrimary.withValues(alpha: 0.16),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    return ClipOval(
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.onPrimary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: avatarUrl.trim().isEmpty
            ? fallback
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

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
                eyebrow,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.15,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.52),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: 1,
                indent: 58.w,
                color: colors.outlineVariant.withValues(alpha: 0.48),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = destructive ? colors.error : colors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(9.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      )
                    : Icon(icon, size: 18.r, color: accent),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: destructive ? colors.error : colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19.r,
                color: destructive
                    ? colors.error.withValues(alpha: 0.75)
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactThemePicker extends StatelessWidget {
  const _CompactThemePicker();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ThemeProvider>();
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.52),
        ),
      ),
      child: Row(
        children: [
          _ThemeChoice(
            label: 'System',
            icon: Icons.settings_suggest_outlined,
            mode: ThemeMode.system,
            selected: provider.themeMode == ThemeMode.system,
          ),
          _ThemeChoice(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            mode: ThemeMode.light,
            selected: provider.themeMode == ThemeMode.light,
          ),
          _ThemeChoice(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            mode: ThemeMode.dark,
            selected: provider.themeMode == ThemeMode.dark,
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final ThemeMode mode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('settings-theme-${mode.name}'),
          onTap: () => context.read<ThemeProvider>().setThemeMode(mode),
          borderRadius: BorderRadius.circular(11.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16.r,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                SizedBox(width: 5.w),
                Text(
                  label,
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

class _SettingsAmbientBackground extends StatelessWidget {
  const _SettingsAmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _SettingsGlow(
              color: colors.primary,
              size: 250.r,
              top: -150.h,
              right: -130.w,
            ),
            _SettingsGlow(
              color: colors.secondary,
              size: 190.r,
              top: 470.h,
              left: -132.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGlow extends StatelessWidget {
  const _SettingsGlow({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.left,
  });

  final Color color;
  final double size;
  final double? top;
  final double? right;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.035),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 85.r,
              spreadRadius: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

String _nameFromEmail(String email) {
  final local = email.split('@').first.trim();
  return local.isEmpty ? 'Your account' : local;
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2);
  final initials = parts.map((part) => part[0].toUpperCase()).join();
  return initials.isEmpty ? 'P' : initials;
}
