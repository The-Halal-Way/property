import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/widgets/entity_form.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  static const _profileFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'employee-name',
      label: 'Name *',
      hint: 'Employee name',
      icon: Icons.person_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    ),
    DynamicTextFieldDefinition(
      id: 'designation',
      label: 'Designation (optional)',
      hint: 'Property manager, accountant…',
      icon: Icons.work_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'phone',
      label: 'Phone (optional)',
      hint: '+880…',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'photo-url',
      label: 'Photo URL (optional)',
      hint: 'https://…',
      icon: Icons.add_photo_alternate_rounded,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
    ),
  ];

  static const _roleFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'role',
      label: 'Role (optional)',
      hint: 'Manager, auditor, caretaker…',
      icon: Icons.admin_panel_settings_rounded,
      fullWidth: true,
    ),
  ];

  static const _loginFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'email',
      label: 'Login email *',
      hint: 'name@example.com',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'password',
      label: 'Temporary password *',
      hint: 'Enter a secure password',
      icon: Icons.password_rounded,
      textCapitalization: TextCapitalization.none,
      obscureText: true,
    ),
  ];

  static const _notesFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'notes',
      label: 'Notes (optional)',
      hint: 'Responsibilities, schedule, or anything useful',
      icon: Icons.notes_rounded,
      fullWidth: true,
      minLines: 3,
      maxLines: 5,
    ),
  ];

  static const _permissions = <String>[
    'properties.view',
    'properties.create',
    'properties.update',
    'properties.delete',
    'units.manage',
    'tenants.view',
    'tenants.create',
    'tenants.update',
    'tenants.delete',
    'leases.manage',
    'invoices.view',
    'invoices.generate',
    'payments.create',
    'reports.view',
    'employees.manage',
    'roles.manage',
  ];

  late final Map<String, TextEditingController> _controllers;
  final Set<String> _selectedPermissions = {};
  bool _loginEnabled = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in [
        ..._profileFields,
        ..._roleFields,
        ..._loginFields,
        ..._notesFields,
      ])
        field.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {}

  @override
  Widget build(BuildContext context) {
    return EntityFormScaffold(
      pageId: 'add-employee',
      eyebrow: 'NEW TEAM MEMBER',
      title: 'Add employee',
      description:
          'Create a simple team profile, then grant only the access this person needs.',
      icon: Icons.person_add_rounded,
      submitLabel: 'Add employee',
      onSubmit: _submit,
      children: [
        EntityFormSection(
          title: 'Employee profile',
          subtitle: 'The details shown across your team directory',
          icon: Icons.badge_rounded,
          child: DynamicTextFieldGrid(
            fields: _profileFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Role & login',
          subtitle: 'Choose their place on the team and sign-in access',
          icon: Icons.lock_person_rounded,
          child: Column(
            children: [
              DynamicTextFieldGrid(
                fields: _roleFields,
                controllers: _controllers,
              ),
              SizedBox(height: 13.h),
              _LoginAccessSwitch(
                value: _loginEnabled,
                onChanged: (value) => setState(() => _loginEnabled = value),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: !_loginEnabled
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(top: 13.h),
                        child: DynamicTextFieldGrid(
                          fields: _loginFields,
                          controllers: _controllers,
                        ),
                      ),
              ),
            ],
          ),
        ),
        EntityFormSection(
          title: 'Extra permissions',
          subtitle: 'Tap to add direct access beyond the selected role',
          icon: Icons.key_rounded,
          child: _PermissionPicker(
            permissions: _permissions,
            selected: _selectedPermissions,
            onChanged: (permission, selected) {
              setState(() {
                if (selected) {
                  _selectedPermissions.add(permission);
                } else {
                  _selectedPermissions.remove(permission);
                }
              });
            },
          ),
        ),
        EntityFormSection(
          title: 'Notes',
          subtitle: 'Private context for the rest of the team',
          icon: Icons.sticky_note_2_rounded,
          child: DynamicTextFieldGrid(
            fields: _notesFields,
            controllers: _controllers,
          ),
        ),
      ],
    );
  }
}

class _LoginAccessSwitch extends StatelessWidget {
  const _LoginAccessSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 7.h, 7.w, 7.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: value
              ? colors.primary.withValues(alpha: 0.42)
              : colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
            color: value ? colors.primary : colors.onSurfaceVariant,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow employee to sign in',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value ? 'Login fields are now available' : 'Profile only',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            key: const ValueKey('employee-login-access-switch'),
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PermissionPicker extends StatelessWidget {
  const _PermissionPicker({
    required this.permissions,
    required this.selected,
    required this.onChanged,
  });

  final List<String> permissions;
  final Set<String> selected;
  final void Function(String permission, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: permissions.map((permission) {
        final isSelected = selected.contains(permission);
        return FilterChip(
          key: ValueKey('permission-$permission'),
          selected: isSelected,
          onSelected: (value) => onChanged(permission, value),
          showCheckmark: false,
          avatar: Icon(
            isSelected ? Icons.check_rounded : Icons.add_rounded,
            size: 15.r,
          ),
          label: Text(permission),
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: isSelected
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.42)
                : colors.outlineVariant.withValues(alpha: 0.52),
          ),
        );
      }).toList(),
    );
  }
}
