import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'data/address_store.dart';

/// Add or edit one saved address. Pops `true` when something was saved.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.existing});

  final SavedAddress? existing;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _label = TextEditingController(text: widget.existing?.label ?? '');
  late final _contactName = TextEditingController(
    text: widget.existing?.contactName ?? '',
  );
  late final _contactPhone = TextEditingController(
    text: widget.existing?.contactPhone ?? '',
  );
  late final _line1 = TextEditingController(text: widget.existing?.line1 ?? '');
  late final _line2 = TextEditingController(text: widget.existing?.line2 ?? '');
  late final _landmark = TextEditingController(
    text: widget.existing?.landmark ?? '',
  );
  late final _city = TextEditingController(text: widget.existing?.city ?? '');
  late final _state = TextEditingController(text: widget.existing?.state ?? '');
  late final _zip = TextEditingController(text: widget.existing?.zip ?? '');

  late bool _isDefault = widget.existing?.isDefault ?? false;
  bool _saving = false;

  static const List<String> _quickLabels = [
    'Factory',
    'Head Office',
    'Warehouse',
    'Workshop',
    'Home',
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    for (final c in [
      _label,
      _contactName,
      _contactPhone,
      _line1,
      _line2,
      _landmark,
      _city,
      _state,
      _zip,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final address = SavedAddress(
      id: widget.existing?.id ?? '',
      label: _label.text.trim().isEmpty ? 'Address' : _label.text.trim(),
      contactName: _contactName.text.trim(),
      contactPhone: _contactPhone.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      landmark: _landmark.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      zip: _zip.text.trim(),
      isDefault: _isDefault,
    );

    final store = AddressStore.instance;
    final result = _isEditing
        ? await store.update(address)
        : await store.add(address);

    if (!mounted) return;
    setState(() => _saving = false);

    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not save')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Address updated' : 'Address saved')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Address' : 'Add Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const _GroupLabel('Label this address'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in _quickLabels)
                  ChoiceChip(
                    label: Text(label),
                    selected: _label.text.trim() == label,
                    onSelected: (_) => setState(() => _label.text = label),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            AddressField(
              key: const ValueKey('address-label'),
              label: 'Address Label',
              controller: _label,
              hint: 'Factory, Head Office...',
              required: true,
            ),
            const SizedBox(height: 22),

            const _GroupLabel('Address'),
            const SizedBox(height: 10),
            AddressField(
              key: const ValueKey('address-line1'),
              label: 'Address Line 1',
              controller: _line1,
              hint: 'Plot / building / street',
              required: true,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            AddressField(
              label: 'Address Line 2',
              controller: _line2,
              hint: 'Area, industrial estate (optional)',
            ),
            const SizedBox(height: 14),
            AddressField(
              label: 'Landmark',
              controller: _landmark,
              hint: 'Near... (optional)',
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AddressField(
                    label: 'City',
                    controller: _city,
                    required: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AddressField(
                    label: 'State',
                    controller: _state,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AddressField(
              key: const ValueKey('address-zip'),
              label: 'PIN Code',
              controller: _zip,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              required: true,
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return 'PIN code is required';
                if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                  return 'Enter a valid 6-digit PIN';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            const _GroupLabel('Contact at this site'),
            const SizedBox(height: 10),
            AddressField(
              label: 'Contact Person',
              controller: _contactName,
              hint: 'Who receives the machine (optional)',
            ),
            const SizedBox(height: 14),
            AddressField(
              key: const ValueKey('address-phone'),
              label: 'Contact Mobile',
              controller: _contactPhone,
              keyboardType: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                final v = (value ?? '').trim();
                if (v.isEmpty) return null; // optional
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                  return 'Enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            SwitchListTile.adaptive(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Use as my default address',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Orders and installations default to this site',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Save address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Labelled text field with the red asterisk convention for required inputs.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.formatters,
    this.validator,
    this.required = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final bool required;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator:
              validator ??
              (required
                  ? (value) => (value ?? '').trim().isEmpty
                        ? '$label is required'
                        : null
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.brandBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
