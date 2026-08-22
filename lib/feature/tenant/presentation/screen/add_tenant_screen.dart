import 'package:flutter/material.dart';
import 'package:property/core/widgets/entity_form.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  static const _profileFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'full-name',
      label: 'Full name *',
      hint: 'Tenant name',
      icon: Icons.person_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    ),
    DynamicTextFieldDefinition(
      id: 'phone',
      label: 'Phone *',
      hint: '+880…',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'email',
      label: 'Email (optional)',
      hint: 'name@example.com',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'id-document-type',
      label: 'ID document type (optional)',
      hint: 'NID, passport, driving licence…',
      icon: Icons.contact_page_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'id-number',
      label: 'ID number (optional)',
      icon: Icons.numbers_rounded,
      textCapitalization: TextCapitalization.characters,
    ),
    DynamicTextFieldDefinition(
      id: 'id-document-url',
      label: 'ID document URL (optional)',
      hint: 'Private file link',
      icon: Icons.upload_file_rounded,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      fullWidth: true,
    ),
  ];

  static const _addressFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'address-line-1',
      label: 'Address line 1 (optional)',
      icon: Icons.location_on_rounded,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'address-line-2',
      label: 'Address line 2 (optional)',
      icon: Icons.add_location_alt_rounded,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'city',
      label: 'City (optional)',
      icon: Icons.location_city_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'state',
      label: 'State / region (optional)',
      icon: Icons.map_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'postal-code',
      label: 'Postal code (optional)',
      icon: Icons.markunread_mailbox_rounded,
      keyboardType: TextInputType.streetAddress,
    ),
    DynamicTextFieldDefinition(
      id: 'country',
      label: 'Country (optional)',
      hint: 'Bangladesh',
      icon: Icons.public_rounded,
    ),
  ];

  static const _householdFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'emergency-contact-name',
      label: 'Emergency contact name (optional)',
      icon: Icons.emergency_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    ),
    DynamicTextFieldDefinition(
      id: 'emergency-contact-phone',
      label: 'Emergency contact phone (optional)',
      icon: Icons.phone_in_talk_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'relation',
      label: 'Relation (optional)',
      hint: 'Spouse, parent, sibling…',
      icon: Icons.diversity_1_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'household-size',
      label: 'Household size (optional)',
      icon: Icons.groups_rounded,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.none,
    ),
    DynamicTextFieldDefinition(
      id: 'guardian-name',
      label: 'Guardian name (optional)',
      icon: Icons.supervisor_account_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
    ),
    DynamicTextFieldDefinition(
      id: 'guardian-phone',
      label: 'Guardian phone (optional)',
      icon: Icons.contact_phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
    ),
  ];

  static const _notesFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'notes',
      label: 'Notes (optional)',
      hint: 'Preferences, context, or anything your team should know',
      icon: Icons.notes_rounded,
      fullWidth: true,
      minLines: 3,
      maxLines: 5,
    ),
  ];

  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in [
        ..._profileFields,
        ..._addressFields,
        ..._householdFields,
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
      pageId: 'add-tenant',
      eyebrow: 'NEW TENANT',
      title: 'Add tenant',
      description:
          'Capture the person first. Their unit, lease, rent, and deposit can be connected afterward.',
      icon: Icons.person_add_alt_1_rounded,
      submitLabel: 'Add tenant',
      onSubmit: _submit,
      children: [
        EntityFormSection(
          title: 'Tenant profile',
          subtitle: 'Identity and primary contact details',
          icon: Icons.account_circle_rounded,
          child: DynamicTextFieldGrid(
            fields: _profileFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Address',
          subtitle: 'Optional permanent or current address',
          icon: Icons.home_work_rounded,
          child: DynamicTextFieldGrid(
            fields: _addressFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Emergency & household',
          subtitle: 'Helpful people and household context',
          icon: Icons.health_and_safety_rounded,
          child: DynamicTextFieldGrid(
            fields: _householdFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Notes',
          subtitle: 'Keep useful context close to the tenant profile',
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
