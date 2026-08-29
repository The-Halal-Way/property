import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/core/widgets/entity_form.dart';
import 'package:property/feature/auth/data/auth_repository.dart';
import 'package:property/feature/settings/data/datasource/profile_remote_data_source.dart';
import 'package:property/feature/settings/data/model/profile_model.dart';
import 'package:property/feature/settings/data/model/update_profile_request.dart';
import 'package:property/feature/settings/data/repository/profile_repository.dart';
import 'package:property/feature/settings/data/repository/profile_repository_impl.dart';

enum AccountSettingsSection { profile, preferences, password }

class AccountSettingsRoutePage extends StatelessWidget {
  const AccountSettingsRoutePage({
    super.key,
    required this.initialSection,
    this.initialProfile,
  });

  final AccountSettingsSection initialSection;
  final ProfileModel? initialProfile;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().currentUser;
    final profile = initialProfile;
    final userEmail = user?.email?.trim() ?? '';
    final profileName = profile?.name.trim() ?? '';
    final userName = user?.displayName?.trim() ?? '';

    return AccountSettingsScreen(
      initialSection: initialSection,
      initialName: profileName.isNotEmpty
          ? profileName
          : userName.isNotEmpty
          ? userName
          : _nameFromEmail(userEmail),
      initialEmail: profile?.email.trim().isNotEmpty == true
          ? profile!.email
          : userEmail,
      initialPhone: profile?.phone ?? user?.phoneNumber ?? '',
      initialAvatarUrl: profile?.avatarUrl.trim().isNotEmpty == true
          ? profile!.avatarUrl
          : user?.photoURL ?? '',
      initialCurrency: profile?.currency ?? '',
      initialCountryCode: profile?.countryCode ?? '',
      initialTimezone: profile?.timezone ?? '',
      initialLocale: profile?.locale ?? '',
      currencyLocked: profile?.currencyLocked ?? false,
      emailVerified: profile?.emailVerified ?? user?.emailVerified ?? false,
    );
  }
}

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({
    super.key,
    this.initialSection = AccountSettingsSection.profile,
    this.profileRepository,
    this.initialName = '',
    this.initialEmail = '',
    this.initialPhone = '',
    this.initialAvatarUrl = '',
    this.initialCurrency = '',
    this.initialCountryCode = '',
    this.initialTimezone = '',
    this.initialLocale = '',
    this.currencyLocked = false,
    this.emailVerified = false,
  });

  final AccountSettingsSection initialSection;
  final ProfileRepository? profileRepository;
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAvatarUrl;
  final String initialCurrency;
  final String initialCountryCode;
  final String initialTimezone;
  final String initialLocale;
  final bool currencyLocked;
  final bool emailVerified;

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  static const _profileFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'profile-name',
      label: 'Full name *',
      icon: Icons.person_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      isRequired: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-email',
      label: 'Email *',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      isRequired: true,
      maxLength: 255,
      validator: _validateEmail,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-phone',
      label: 'Phone (optional)',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      maxLength: 30,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-address-line1',
      label: 'Address line 1 (optional)',
      icon: Icons.location_on_rounded,
      maxLength: 255,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-address-line2',
      label: 'Address line 2 (optional)',
      icon: Icons.add_location_alt_rounded,
      maxLength: 255,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-city',
      label: 'City (optional)',
      icon: Icons.location_city_rounded,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-state',
      label: 'State / region (optional)',
      icon: Icons.map_rounded,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-postal-code',
      label: 'Postal code (optional)',
      icon: Icons.markunread_mailbox_rounded,
      keyboardType: TextInputType.streetAddress,
      maxLength: 20,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-country-code',
      label: 'Country code (optional)',
      hint: 'BD',
      icon: Icons.public_rounded,
      textCapitalization: TextCapitalization.characters,
      maxLength: 2,
      validator: _validateOptionalCountryCode,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-timezone',
      label: 'Timezone (optional)',
      hint: 'Asia/Dhaka',
      icon: Icons.schedule_rounded,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'profile-locale',
      label: 'Locale (optional)',
      hint: 'en-BD',
      icon: Icons.translate_rounded,
      textCapitalization: TextCapitalization.none,
      maxLength: 10,
      fullWidth: true,
    ),
  ];

  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late AccountSettingsSection _section;
  late String _currency;
  ProfileModel? _updatedProfile;
  bool _isSavingProfile = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _currency = _supportedCurrencies.contains(widget.initialCurrency)
        ? widget.initialCurrency
        : 'BDT';
    _controllers = {
      for (final field in _profileFields)
        field.id: TextEditingController(text: _initialValue(field.id)),
    };
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _initialValue(String id) => switch (id) {
    'profile-name' => widget.initialName,
    'profile-email' => widget.initialEmail,
    'profile-phone' => widget.initialPhone,
    'profile-country-code' => widget.initialCountryCode,
    'profile-timezone' => widget.initialTimezone,
    'profile-locale' => widget.initialLocale,
    _ => '',
  };

  String _value(String id) => _controllers[id]!.text.trim();

  Future<void> _saveProfile() async {
    if (_isSavingProfile ||
        !(_profileFormKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSavingProfile = true);
    final request = UpdateProfileRequest(
      name: _value('profile-name'),
      email: _value('profile-email'),
      phone: _value('profile-phone'),
      addressLine1: _value('profile-address-line1'),
      addressLine2: _value('profile-address-line2'),
      city: _value('profile-city'),
      state: _value('profile-state'),
      postalCode: _value('profile-postal-code'),
      countryCode: _value('profile-country-code'),
      timezone: _value('profile-timezone'),
      locale: _value('profile-locale'),
    );

    try {
      final repository =
          widget.profileRepository ??
          ProfileRepositoryImpl(BaseClientProfileRemoteDataSource(context));
      final profile = await repository.updateProfile(request);
      if (!mounted) return;
      _updatedProfile = profile;
      _applyResponse(profile);
      setState(() => _isSavingProfile = false);
      MyDialog().showSuccessToast(msg: 'Profile updated.', context: context);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(profile);
      }
    } on ApiRequestException catch (error) {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      if (!error.reported) _showProfileFailure();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingProfile = false);
      _showProfileFailure();
    }
  }

  void _applyResponse(ProfileModel profile) {
    final responseValues = <String, String>{
      'profile-name': profile.name,
      'profile-email': profile.email,
      'profile-phone': profile.phone,
      'profile-country-code': profile.countryCode,
      'profile-timezone': profile.timezone,
      'profile-locale': profile.locale,
    };
    for (final entry in responseValues.entries) {
      _controllers[entry.key]!.text = entry.value;
    }
    if (_supportedCurrencies.contains(profile.currency)) {
      _currency = profile.currency;
    }
  }

  void _showProfileFailure() {
    MyDialog().showFailedToast(
      msg: 'The profile could not be updated. Please try again.',
      context: context,
    );
  }

  void _close() {
    Navigator.of(context).pop(_updatedProfile);
  }

  void _previewPreferenceSave() {
    MyDialog().showInfoToast(
      title: 'API pending',
      msg: 'Currency updates will be connected when the API is available.',
      context: context,
    );
  }

  void _previewPasswordSave() {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    MyDialog().showInfoToast(
      title: 'API pending',
      msg: 'Password updates will be connected when the API is available.',
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      key: const ValueKey('account-settings-page'),
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const _AccountAmbientBackground(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              key: const ValueKey('account-settings-scroll-view'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18.w, 13.h, 18.w, 34.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AccountHeader(onBack: _close),
                            SizedBox(height: 15.h),
                            _AccountTabs(
                              selected: _section,
                              onChanged: (section) =>
                                  setState(() => _section = section),
                            ),
                            SizedBox(height: 13.h),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              child: switch (_section) {
                                AccountSettingsSection.profile =>
                                  _buildProfileSection(),
                                AccountSettingsSection.preferences =>
                                  _buildPreferencesSection(),
                                AccountSettingsSection.password =>
                                  _buildPasswordSection(),
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.paddingOf(context).bottom,
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

  Widget _buildProfileSection() {
    final profile = _updatedProfile;
    final avatarUrl = profile?.avatarUrl.trim().isNotEmpty == true
        ? profile!.avatarUrl
        : widget.initialAvatarUrl;
    final isVerified = profile?.emailVerified ?? widget.emailVerified;

    return _AccountPanel(
      key: const ValueKey('account-profile-section'),
      eyebrow: 'PROFILE',
      title: 'Personal details',
      description: 'Keep your contact and regional information current.',
      icon: Icons.person_outline_rounded,
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileIdentity(
              name: _value('profile-name'),
              email: _value('profile-email'),
              avatarUrl: avatarUrl,
              verified: isVerified,
            ),
            SizedBox(height: 16.h),
            DynamicTextFieldGrid(
              fields: _profileFields,
              controllers: _controllers,
            ),
            SizedBox(height: 17.h),
            FilledButton.icon(
              key: const ValueKey('profile-save-button'),
              onPressed: _isSavingProfile ? null : _saveProfile,
              icon: _isSavingProfile
                  ? SizedBox.square(
                      dimension: 17.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSavingProfile ? 'Saving…' : 'Save profile'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final colors = Theme.of(context).colorScheme;
    return _AccountPanel(
      key: const ValueKey('account-preferences-section'),
      eyebrow: 'PREFERENCES',
      title: 'Money display',
      description: 'Choose the currency used across portfolio values.',
      icon: Icons.tune_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: const ValueKey('preference-currency-field'),
            initialValue: _currency,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: _supportedCurrencies
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency,
                    child: Text('$currency  ·  ${_currencyName(currency)}'),
                  ),
                )
                .toList(growable: false),
            onChanged: widget.currencyLocked
                ? null
                : (value) => setState(() => _currency = value ?? _currency),
          ),
          SizedBox(height: 11.h),
          _PendingApiNotice(
            icon: widget.currencyLocked
                ? Icons.lock_outline_rounded
                : Icons.info_outline_rounded,
            message: widget.currencyLocked
                ? 'Your account currency is locked.'
                : 'Currency changes are ready for the upcoming API.',
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            key: const ValueKey('preference-save-button'),
            onPressed: widget.currencyLocked ? null : _previewPreferenceSave,
            icon: Icon(Icons.schedule_send_rounded, color: colors.primary),
            label: const Text('Save when API is connected'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return _AccountPanel(
      key: const ValueKey('account-password-section'),
      eyebrow: 'PASSWORD',
      title: 'Change password',
      description: 'Prepare a new password and confirm it before updating.',
      icon: Icons.password_rounded,
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('new-password-field'),
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if ((value ?? '').isEmpty) return 'New password is required.';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscureNewPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            SizedBox(height: 13.h),
            TextFormField(
              key: const ValueKey('confirm-password-field'),
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Confirm password is required.';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscureConfirmPassword
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            SizedBox(height: 11.h),
            const _PendingApiNotice(
              icon: Icons.info_outline_rounded,
              message: 'Password changes are ready for the upcoming API.',
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              key: const ValueKey('password-update-button'),
              onPressed: _previewPasswordSave,
              icon: const Icon(Icons.schedule_send_rounded),
              label: const Text('Update when API is connected'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        IconButton.filledTonal(
          key: const ValueKey('account-settings-back-button'),
          tooltip: 'Back to settings',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACCOUNT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.35,
                ),
              ),
              Text(
                'Your settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Icons.manage_accounts_rounded, color: colors.onPrimary),
        ),
      ],
    );
  }
}

class _AccountTabs extends StatelessWidget {
  const _AccountTabs({required this.selected, required this.onChanged});

  final AccountSettingsSection selected;
  final ValueChanged<AccountSettingsSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.48),
        ),
      ),
      child: Row(
        children: [
          for (final section in AccountSettingsSection.values)
            Expanded(
              child: _AccountTab(
                section: section,
                selected: section == selected,
                onTap: () => onChanged(section),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AccountSettingsSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (label, icon) = switch (section) {
      AccountSettingsSection.profile => (
        'Profile',
        Icons.person_outline_rounded,
      ),
      AccountSettingsSection.preferences => ('Preferences', Icons.tune_rounded),
      AccountSettingsSection.password => ('Password', Icons.password_rounded),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('account-tab-${section.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.91),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(25.r),
        ),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.045),
            blurRadius: 22.r,
            offset: Offset(0, 9.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39.r,
                height: 39.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(icon, color: colors.primary, size: 19.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.secondary,
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
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.verified,
  });

  final String name;
  final String email;
  final String avatarUrl;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _ProfileAvatar(name: name, avatarUrl: avatarUrl),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.trim().isEmpty ? 'Your profile' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  email.trim().isEmpty ? 'Add your account email' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (verified)
            Tooltip(
              message: 'Email verified',
              child: Icon(
                Icons.verified_rounded,
                color: colors.primary,
                size: 19.r,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Container(
      color: colors.primary,
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
      child: SizedBox.square(
        dimension: 51.r,
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

class _PendingApiNotice extends StatelessWidget {
  const _PendingApiNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17.r, color: colors.onSecondaryContainer),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountAmbientBackground extends StatelessWidget {
  const _AccountAmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _AccountGlow(
              color: colors.primary,
              size: 260.r,
              top: -145.h,
              right: -130.w,
            ),
            _AccountGlow(
              color: colors.secondary,
              size: 205.r,
              top: 420.h,
              left: -140.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountGlow extends StatelessWidget {
  const _AccountGlow({
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
          color: color.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.13),
              blurRadius: 86.r,
              spreadRadius: 21.r,
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return null;
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? null
      : 'Enter a valid email address.';
}

String? _validateOptionalCountryCode(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty || RegExp(r'^[A-Za-z]{2}$').hasMatch(code)) return null;
  return 'Enter a 2-letter country code.';
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList(growable: false);
  if (parts.isEmpty) return 'P';
  return parts.map((part) => part[0].toUpperCase()).join();
}

String _nameFromEmail(String email) {
  final local = email.split('@').first.trim();
  return local.isEmpty ? 'Your account' : local;
}

const _supportedCurrencies = <String>['BDT', 'USD', 'EUR', 'GBP', 'INR'];

String _currencyName(String currency) => switch (currency) {
  'BDT' => 'Bangladeshi taka',
  'USD' => 'US dollar',
  'EUR' => 'Euro',
  'GBP' => 'British pound',
  'INR' => 'Indian rupee',
  _ => currency,
};
