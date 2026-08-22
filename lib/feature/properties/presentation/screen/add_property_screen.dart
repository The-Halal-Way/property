import 'package:flutter/material.dart';
import 'package:property/core/widgets/entity_form.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  static const _identityFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'property-name',
      label: 'Property name *',
      hint: 'e.g. Aurora Heights',
      icon: Icons.apartment_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'property-type',
      label: 'Property type *',
      hint: 'Apartment, house, commercial…',
      icon: Icons.category_rounded,
    ),
    DynamicTextFieldDefinition(
      id: 'managed-by',
      label: 'Managed by (optional)',
      hint: 'Employee or team name',
      icon: Icons.badge_rounded,
      fullWidth: true,
    ),
  ];

  static const _valueFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'current-value',
      label: 'Current property value (optional)',
      hint: '0.00',
      icon: Icons.trending_up_rounded,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
    DynamicTextFieldDefinition(
      id: 'purchase-price',
      label: 'Purchase price (optional)',
      hint: '0.00',
      icon: Icons.payments_rounded,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
  ];

  static const _addressFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'address-line-1',
      label: 'Address line 1 *',
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
      label: 'City *',
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
      label: 'Country *',
      hint: 'Bangladesh',
      icon: Icons.public_rounded,
    ),
  ];

  static const _additionalFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'photo-url',
      label: 'Property photo URL (optional)',
      hint: 'https://…',
      icon: Icons.add_photo_alternate_rounded,
      keyboardType: TextInputType.url,
      textCapitalization: TextCapitalization.none,
      fullWidth: true,
    ),
    DynamicTextFieldDefinition(
      id: 'notes',
      label: 'Notes (optional)',
      hint: 'Add anything your team should know',
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
        ..._identityFields,
        ..._valueFields,
        ..._addressFields,
        ..._additionalFields,
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
      pageId: 'add-property',
      eyebrow: 'NEW PROPERTY',
      title: 'Add property',
      description:
          'Build the property profile now. Units and lease details can be connected afterward.',
      icon: Icons.apartment_rounded,
      submitLabel: 'Create property',
      onSubmit: _submit,
      children: [
        EntityFormSection(
          title: 'Property profile',
          subtitle: 'The basics people will use to identify it',
          icon: Icons.domain_add_rounded,
          child: DynamicTextFieldGrid(
            fields: _identityFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Financial snapshot',
          subtitle: 'Optional values for portfolio reporting',
          icon: Icons.account_balance_wallet_rounded,
          child: DynamicTextFieldGrid(
            fields: _valueFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Address',
          subtitle: 'Where this property belongs',
          icon: Icons.pin_drop_rounded,
          child: DynamicTextFieldGrid(
            fields: _addressFields,
            controllers: _controllers,
          ),
        ),
        EntityFormSection(
          title: 'Finishing touches',
          subtitle: 'A photo reference and any useful context',
          icon: Icons.auto_awesome_rounded,
          child: DynamicTextFieldGrid(
            fields: _additionalFields,
            controllers: _controllers,
          ),
        ),
      ],
    );
  }
}
