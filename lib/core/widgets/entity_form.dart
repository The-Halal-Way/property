import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:property/core/model/selected_upload_file.dart';

/// Describes a text field without tying the form layout to a fixed row.
///
/// [DynamicTextFieldGrid] uses these definitions to switch between one and two
/// columns as space becomes available.
class DynamicTextFieldDefinition {
  const DynamicTextFieldDefinition({
    required this.id,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.obscureText = false,
    this.fullWidth = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.isRequired = false,
    this.maxLength,
    this.validator,
  });

  final String id;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool fullWidth;
  final int minLines;
  final int maxLines;
  final bool isRequired;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
}

class DynamicTextFieldGrid extends StatelessWidget {
  const DynamicTextFieldGrid({
    super.key,
    required this.fields,
    required this.controllers,
  });

  final List<DynamicTextFieldDefinition> fields;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.w;
        final useTwoColumns = constraints.maxWidth >= 590;
        final halfWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 13.h,
          children: fields.map((field) {
            final width = useTwoColumns && !field.fullWidth
                ? halfWidth
                : constraints.maxWidth;

            return SizedBox(
              width: width,
              child: TextFormField(
                key: ValueKey('form-field-${field.id}'),
                controller: controllers[field.id],
                obscureText: field.obscureText,
                keyboardType: field.keyboardType,
                textCapitalization: field.textCapitalization,
                minLines: field.obscureText ? 1 : field.minLines,
                maxLines: field.obscureText ? 1 : field.maxLines,
                textInputAction: field.maxLines > 1
                    ? TextInputAction.newline
                    : TextInputAction.next,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final fieldName = field.label
                      .replaceAll('(optional)', '')
                      .replaceAll('*', '')
                      .trim();
                  if (field.isRequired && trimmed.isEmpty) {
                    return '$fieldName is required.';
                  }
                  final maxLength = field.maxLength;
                  if (maxLength != null && trimmed.length > maxLength) {
                    return '$fieldName must be $maxLength characters or less.';
                  }
                  return field.validator?.call(value);
                },
                decoration: InputDecoration(
                  labelText: field.label,
                  hintText: field.hint,
                  alignLabelWithHint: field.maxLines > 1,
                  prefixIcon: field.icon == null ? null : Icon(field.icon),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class EntityFormSection extends StatelessWidget {
  const EntityFormSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(17.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(13.r),
          bottomLeft: Radius.circular(13.r),
          bottomRight: Radius.circular(25.r),
        ),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.46),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.035),
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
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(icon, size: 19.r, color: colors.primary),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 17.h),
          child,
        ],
      ),
    );
  }
}

class EntityFormScaffold extends StatelessWidget {
  const EntityFormScaffold({
    super.key,
    required this.pageId,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.submitLabel,
    required this.onSubmit,
    required this.children,
    this.formKey,
    this.isSubmitting = false,
  });

  final String pageId;
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final String submitLabel;
  final VoidCallback onSubmit;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 700 ? 24.w : 18.w;

    return Scaffold(
      key: ValueKey('$pageId-page'),
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const _EntityFormAmbientBackground(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              key: ValueKey('$pageId-scroll-view'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14.h,
                    horizontalPadding,
                    38.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _EntityFormHeader(
                                eyebrow: eyebrow,
                                title: title,
                                icon: icon,
                                onBack: () => Navigator.of(context).maybePop(),
                              ),
                              SizedBox(height: 20.h),
                              _EntityFormIntro(
                                description: description,
                                icon: icon,
                              ),
                              SizedBox(height: 16.h),
                              for (
                                var index = 0;
                                index < children.length;
                                index++
                              ) ...[
                                children[index],
                                if (index != children.length - 1)
                                  SizedBox(height: 13.h),
                              ],
                              SizedBox(height: 20.h),
                              FilledButton.icon(
                                key: ValueKey('$pageId-submit-button'),
                                onPressed: isSubmitting ? null : onSubmit,
                                icon: isSubmitting
                                    ? SizedBox.square(
                                        dimension: 18.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  isSubmitting ? 'Saving…' : submitLabel,
                                ),
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EntityFilePickerField extends StatefulWidget {
  const EntityFilePickerField({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedFile,
    required this.onChanged,
    this.imagesOnly = false,
    this.allowedExtensions,
    this.maxSizeInBytes = 5 * 1024 * 1024,
  });

  final String id;
  final String label;
  final IconData icon;
  final SelectedUploadFile? selectedFile;
  final ValueChanged<SelectedUploadFile?> onChanged;
  final bool imagesOnly;
  final List<String>? allowedExtensions;
  final int maxSizeInBytes;

  @override
  State<EntityFilePickerField> createState() => _EntityFilePickerFieldState();
}

class _EntityFilePickerFieldState extends State<EntityFilePickerField> {
  bool _isPicking = false;
  String? _errorText;

  Future<void> _pickFile() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _errorText = null;
    });

    try {
      final extensions = widget.allowedExtensions;
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
        type: widget.imagesOnly
            ? FileType.image
            : extensions == null
            ? FileType.any
            : FileType.custom,
        allowedExtensions: widget.imagesOnly ? null : extensions,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      final bytes = picked.bytes;
      if (bytes == null) {
        setState(() => _errorText = 'The selected file could not be read.');
        return;
      }
      if (bytes.lengthInBytes > widget.maxSizeInBytes) {
        final maxMegabytes = widget.maxSizeInBytes / (1024 * 1024);
        setState(
          () => _errorText =
              'Choose a file no larger than ${maxMegabytes.toStringAsFixed(0)} MB.',
        );
        return;
      }

      widget.onChanged(SelectedUploadFile(name: picked.name, bytes: bytes));
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'The file picker could not be opened.');
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedFile = widget.selectedFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            key: ValueKey('file-picker-${widget.id}'),
            onTap: _isPicking ? null : _pickFile,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _errorText == null
                      ? colors.outlineVariant.withValues(alpha: 0.55)
                      : colors.error,
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: colors.primary, size: 21.r),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          selectedFile?.name ??
                              'Tap to choose a file (max 5 MB)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selectedFile == null
                                ? colors.onSurfaceVariant
                                : colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isPicking)
                    SizedBox.square(
                      dimension: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (selectedFile != null)
                    IconButton(
                      key: ValueKey('file-picker-${widget.id}-clear'),
                      tooltip: 'Remove file',
                      onPressed: () => widget.onChanged(null),
                      icon: const Icon(Icons.close_rounded),
                    )
                  else
                    const Icon(Icons.upload_rounded),
                ],
              ),
            ),
          ),
        ),
        if (_errorText case final error?) ...[
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _EntityFormHeader extends StatelessWidget {
  const _EntityFormHeader({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.onBack,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Tooltip(
          message: 'Back',
          child: Material(
            color: colors.surfaceContainerLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(15.r),
            child: InkWell(
              key: const ValueKey('entity-form-back-button'),
              onTap: onBack,
              borderRadius: BorderRadius.circular(15.r),
              child: Container(
                width: 43.r,
                height: 43.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.48),
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(Icons.arrow_back_rounded, size: 20.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 43.r,
          height: 43.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                Color.lerp(colors.primary, colors.secondary, 0.45)!,
              ],
            ),
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.22),
                blurRadius: 15.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Icon(icon, color: colors.onPrimary, size: 21.r),
        ),
      ],
    );
  }
}

class _EntityFormIntro extends StatelessWidget {
  const _EntityFormIntro({required this.description, required this.icon});

  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 17.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(colors.primary, Colors.black, 0.2)!,
            Color.lerp(colors.primary, colors.secondary, 0.58)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(29.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(29.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -23.w,
            top: -35.h,
            child: Icon(
              icon,
              size: 112.r,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Row(
            children: [
              Container(
                width: 39.r,
                height: 39.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 19.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntityFormAmbientBackground extends StatelessWidget {
  const _EntityFormAmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            _AmbientGlow(
              color: colors.primary,
              size: 280.r,
              top: -148.h,
              right: -126.w,
            ),
            _AmbientGlow(
              color: colors.secondary,
              size: 225.r,
              top: 410.h,
              left: -150.w,
            ),
            _AmbientGlow(
              color: colors.tertiary,
              size: 185.r,
              bottom: 45.h,
              right: -125.w,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
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
          color: color.withValues(alpha: 0.035),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.13),
              blurRadius: 92.r,
              spreadRadius: 24.r,
            ),
          ],
        ),
      ),
    );
  }
}
