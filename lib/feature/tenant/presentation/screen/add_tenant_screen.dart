import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/base/base_client.dart';
import 'package:property/core/model/selected_upload_file.dart';
import 'package:property/core/util/my_dialog.dart';
import 'package:property/core/widgets/entity_form.dart';
import 'package:property/feature/tenant/data/datasource/tenant_remote_data_source.dart';
import 'package:property/feature/tenant/data/model/create_tenant_request.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository.dart';
import 'package:property/feature/tenant/data/repository/tenant_repository_impl.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key, this.repository});

  final TenantCreateRepository? repository;

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
      isRequired: true,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'phone',
      label: 'Phone *',
      hint: '+880…',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      isRequired: true,
      maxLength: 30,
    ),
    DynamicTextFieldDefinition(
      id: 'email',
      label: 'Email (optional)',
      hint: 'name@example.com',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      fullWidth: true,
      maxLength: 255,
      validator: _validateTenantEmail,
    ),
    DynamicTextFieldDefinition(
      id: 'id-document-type',
      label: 'ID document type (optional)',
      hint: 'NID, passport, driving licence…',
      icon: Icons.contact_page_rounded,
      maxLength: 50,
    ),
    DynamicTextFieldDefinition(
      id: 'id-number',
      label: 'ID number (optional)',
      icon: Icons.numbers_rounded,
      textCapitalization: TextCapitalization.characters,
      maxLength: 100,
    ),
  ];

  static const _addressFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'address-line-1',
      label: 'Address line 1 (optional)',
      icon: Icons.location_on_rounded,
      fullWidth: true,
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
      label: 'City (optional)',
      icon: Icons.location_city_rounded,
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
      label: 'Country code (optional)',
      hint: 'BD',
      icon: Icons.public_rounded,
      textCapitalization: TextCapitalization.characters,
      maxLength: 2,
      validator: _validateOptionalCountryCode,
    ),
  ];

  static const _householdFields = <DynamicTextFieldDefinition>[
    DynamicTextFieldDefinition(
      id: 'emergency-contact-name',
      label: 'Emergency contact name (optional)',
      icon: Icons.emergency_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'emergency-contact-phone',
      label: 'Emergency contact phone (optional)',
      icon: Icons.phone_in_talk_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      maxLength: 30,
    ),
    DynamicTextFieldDefinition(
      id: 'relation',
      label: 'Relation (optional)',
      hint: 'Spouse, parent, sibling…',
      icon: Icons.diversity_1_rounded,
      maxLength: 50,
    ),
    DynamicTextFieldDefinition(
      id: 'household-size',
      label: 'Household size (optional)',
      icon: Icons.groups_rounded,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.none,
      validator: _validateFamilyCount,
    ),
    DynamicTextFieldDefinition(
      id: 'guardian-name',
      label: 'Guardian name (optional)',
      icon: Icons.supervisor_account_rounded,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      maxLength: 255,
    ),
    DynamicTextFieldDefinition(
      id: 'guardian-phone',
      label: 'Guardian phone (optional)',
      icon: Icons.contact_phone_rounded,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      maxLength: 30,
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
      maxLength: 5000,
    ),
  ];

  late final Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();
  SelectedUploadFile? _photo;
  SelectedUploadFile? _idDocument;
  bool _isSubmitting = false;

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

  String _value(String id) => _controllers[id]!.text.trim();

  int? _optionalInt(String id) {
    final value = _value(id);
    return value.isEmpty ? null : int.parse(value);
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final request = CreateTenantRequest(
      name: _value('full-name'),
      phone: _value('phone'),
      email: _value('email'),
      idDocumentType: _value('id-document-type'),
      idDocumentNumber: _value('id-number'),
      addressLine1: _value('address-line-1'),
      addressLine2: _value('address-line-2'),
      city: _value('city'),
      state: _value('state'),
      postalCode: _value('postal-code'),
      countryCode: _value('country-code'),
      emergencyContactName: _value('emergency-contact-name'),
      emergencyContactPhone: _value('emergency-contact-phone'),
      emergencyContactRelation: _value('relation'),
      familyMembersCount: _optionalInt('household-size'),
      guardianName: _value('guardian-name'),
      guardianPhone: _value('guardian-phone'),
      notes: _value('notes'),
      photo: _photo,
      idDocument: _idDocument,
    );

    try {
      final repository =
          widget.repository ??
          TenantRepositoryImpl(BaseClientTenantRemoteDataSource(context));
      final tenant = await repository.createTenant(request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      MyDialog().showSuccessToast(msg: 'Tenant added.', context: context);
      Navigator.of(context).pop(tenant);
    } on ApiRequestException catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (!error.reported) {
        MyDialog().showFailedToast(
          msg: 'The tenant could not be added. Please try again.',
          context: context,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      MyDialog().showFailedToast(
        msg: 'The tenant could not be added. Please try again.',
        context: context,
      );
    }
  }

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
      formKey: _formKey,
      isSubmitting: _isSubmitting,
      children: [
        EntityFormSection(
          title: 'Tenant profile',
          subtitle: 'Identity and primary contact details',
          icon: Icons.account_circle_rounded,
          child: Column(
            children: [
              DynamicTextFieldGrid(
                fields: _profileFields,
                controllers: _controllers,
              ),
              SizedBox(height: 13.h),
              EntityFilePickerField(
                id: 'tenant-photo',
                label: 'Photo (optional)',
                icon: Icons.add_a_photo_rounded,
                imagesOnly: true,
                selectedFile: _photo,
                onChanged: (file) => setState(() => _photo = file),
              ),
              SizedBox(height: 10.h),
              EntityFilePickerField(
                id: 'tenant-id-document',
                label: 'ID document (optional)',
                icon: Icons.upload_file_rounded,
                allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                selectedFile: _idDocument,
                onChanged: (file) => setState(() => _idDocument = file),
              ),
            ],
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

String? _validateTenantEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return null;
  final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  return isValid ? null : 'Enter a valid email address.';
}

String? _validateFamilyCount(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final count = int.tryParse(raw);
  return count != null && count >= 0 && count <= 255
      ? null
      : 'Enter a whole number from 0 to 255.';
}

String? _validateOptionalCountryCode(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty || RegExp(r'^[A-Za-z]{2}$').hasMatch(raw)) return null;
  return 'Enter a 2-letter country code.';
}
