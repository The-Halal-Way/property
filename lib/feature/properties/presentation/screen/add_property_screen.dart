import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/model/selected_upload_file.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/core/widgets/entity_form.dart';
import 'package:property/feature/properties/data/datasource/property_remote_data_source.dart';
import 'package:property/feature/properties/data/model/create_property_request.dart';
import 'package:property/feature/properties/data/repository/property_repository.dart';
import 'package:property/feature/properties/data/repository/property_repository_impl.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key, this.repository});

  final PropertyCreateRepository? repository;

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
      isRequired: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'property-type',
      label: 'Property type *',
      hint: 'Apartment, house, commercial, garage, land, or other',
      icon: Icons.category_rounded,
      isRequired: true,
      validator: _validatePropertyType,
    ),
    DynamicTextFieldDefinition(
      id: 'managed-by',
      label: 'Employee ID (optional)',
      hint: 'Employee responsible for this property',
      icon: Icons.badge_rounded,
      fullWidth: true,
      textCapitalization: TextCapitalization.none,
    ),
  ];

  static const _valueFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'current-value',
      label: 'Current property value (optional)',
      hint: '0.00',
      icon: Icons.trending_up_rounded,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textCapitalization: TextCapitalization.none,
      validator: _validateNonnegativeNumber,
    ),
    DynamicTextFieldDefinition(
      id: 'purchase-price',
      label: 'Purchase price (optional)',
      hint: '0.00',
      icon: Icons.payments_rounded,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textCapitalization: TextCapitalization.none,
      validator: _validateNonnegativeNumber,
    ),
  ];

  static const _addressFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'address-line-1',
      label: 'Address line 1 *',
      icon: Icons.location_on_rounded,
      fullWidth: true,
      isRequired: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'address-line-2',
      label: 'Address line 2 (optional)',
      icon: Icons.add_location_alt_rounded,
      fullWidth: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'city',
      label: 'City *',
      icon: Icons.location_city_rounded,
      isRequired: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'state',
      label: 'State / region (optional)',
      icon: Icons.map_rounded,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'postal-code',
      label: 'Postal code (optional)',
      icon: Icons.markunread_mailbox_rounded,
      keyboardType: TextInputType.streetAddress,
      maxLength: 20,
    ),
    DynamicTextFieldDefinition(
      id: 'country-code',
      label: 'Country code *',
      hint: 'BD',
      icon: Icons.public_rounded,
      textCapitalization: TextCapitalization.characters,
      isRequired: true,
      maxLength: 2,
      validator: _validateCountryCode,
    ),
  ];

  static const _additionalFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'notes',
      label: 'Notes (optional)',
      hint: 'Add anything your team should know',
      icon: Icons.notes_rounded,
      fullWidth: true,
      minLines: 3,
      maxLines: 5,
      maxLength: 5000,
    ),
  ];

  late final Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();
  SelectedUploadFile? _image;
  bool _isSubmitting = false;

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

  String _value(String id) => _controllers[id]!.text.trim();

  double? _optionalNumber(String id) {
    final value = _value(id);
    return value.isEmpty ? null : double.parse(value);
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final request = CreatePropertyRequest(
      name: _value('property-name'),
      type: _value('property-type'),
      employeeId: _value('managed-by'),
      addressLine1: _value('address-line-1'),
      addressLine2: _value('address-line-2'),
      city: _value('city'),
      state: _value('state'),
      postalCode: _value('postal-code'),
      countryCode: _value('country-code'),
      currentValue: _optionalNumber('current-value'),
      purchasePrice: _optionalNumber('purchase-price'),
      notes: _value('notes'),
      image: _image,
    );

    try {
      final repository =
          widget.repository ??
          PropertyRepositoryImpl(BaseClientPropertyRemoteDataSource(context));
      final property = await repository.createProperty(request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      MyDialog().showSuccessToast(msg: 'Property created.', context: context);
      Navigator.of(context).pop(property);
    } on ApiRequestException catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (!error.reported) {
        MyDialog().showFailedToast(
          msg: 'The property could not be created. Please try again.',
          context: context,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      MyDialog().showFailedToast(
        msg: 'The property could not be created. Please try again.',
        context: context,
      );
    }
  }

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
      formKey: _formKey,
      isSubmitting: _isSubmitting,
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
          child: Column(
            children: [
              EntityFilePickerField(
                id: 'property-image',
                label: 'Property image (optional)',
                icon: Icons.add_photo_alternate_rounded,
                imagesOnly: true,
                selectedFile: _image,
                onChanged: (file) => setState(() => _image = file),
              ),
              SizedBox(height: 13.h),
              DynamicTextFieldGrid(
                fields: _additionalFields,
                controllers: _controllers,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String? _validatePropertyType(String? value) {
  const allowed = <String>{
    'apartment',
    'house',
    'commercial',
    'garage',
    'land',
    'other',
  };
  final normalized = value?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty || allowed.contains(normalized)) return null;
  return 'Use apartment, house, commercial, garage, land, or other.';
}

String? _validateNonnegativeNumber(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final number = double.tryParse(raw);
  return number != null && number >= 0
      ? null
      : 'Enter a number greater than or equal to 0.';
}

String? _validateCountryCode(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty || RegExp(r'^[A-Za-z]{2}$').hasMatch(raw)) return null;
  return 'Enter a 2-letter country code.';
}
