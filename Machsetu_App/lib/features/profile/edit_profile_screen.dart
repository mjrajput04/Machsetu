import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import 'data/profile_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _role = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _gstin = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
    // Keeps the avatar monogram in step with the name as it is typed.
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _role,
      _company,
      _email,
      _phone,
      _gstin,
      _address,
      _city,
      _state,
      _zip,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final user = await SessionStore.instance.user();
    if (!mounted) return;
    setState(() {
      _name.text = user.name.isEmpty ? ProfileData.fallbackName : user.name;
      _role.text = user.role.isEmpty ? ProfileData.role : user.role;
      _company.text = user.company.isEmpty ? ProfileData.company : user.company;
      _email.text = user.email;
      _phone.text = user.phone;
      _gstin.text = user.gstin;
      _address.text = user.address;
      _city.text = user.city;
      _state.text = user.state;
      _zip.text = user.zip;
      _loading = false;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await SessionStore.instance.saveProfile(
      SessionUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        role: _role.text.trim(),
        company: _company.text.trim(),
        gstin: _gstin.text.trim().toUpperCase(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        zip: _zip.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _changePhoto() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
            for (final option in const [
              (Icons.photo_camera_outlined, 'Take a photo'),
              (Icons.photo_library_outlined, 'Choose from gallery'),
              (Icons.delete_outline, 'Remove photo'),
            ])
              ListTile(
                leading: Icon(option.$1, size: 21, color: AppColors.brandBlue),
                title: Text(option.$2),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Photo upload needs the image picker — ask to enable '
                        'it',
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String get _initials {
    final parts = _name.text.trim().split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'MS';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _AvatarPicker(
                        initials: _initials,
                        onTap: _changePhoto,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _Group(
                      icon: Icons.person_outline,
                      title: 'Personal Details',
                      children: [
                        _Field(
                          label: 'Full Name',
                          hint: 'Marcus V. Sterling',
                          controller: _name,
                          validator: Validators.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _Field(
                          label: 'Designation',
                          hint: 'Senior Procurement Director',
                          controller: _role,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _Field(
                          label: 'Email Address',
                          hint: 'you@company.com',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        _Field(
                          label: 'Mobile Number',
                          hint: '98765 43210',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Group(
                      icon: Icons.business_outlined,
                      title: 'Company',
                      children: [
                        _Field(
                          label: 'Company Name',
                          hint: 'Aerotech Solutions Inc.',
                          controller: _company,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _Field(
                          label: 'GST / Tax Identification Number',
                          hint: 'GSTIN-9922883311',
                          controller: _gstin,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return null;
                            return value.length < 8
                                ? 'Enter a valid GSTIN'
                                : null;
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Group(
                      icon: Icons.place_outlined,
                      title: 'Delivery Address',
                      children: [
                        _Field(
                          label: 'Street Address / Warehouse Unit',
                          hint: 'Plot 44, Industrial Area Phase II',
                          controller: _address,
                          textCapitalization: TextCapitalization.words,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _Field(
                                label: 'City',
                                hint: 'Pune',
                                controller: _city,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _Field(
                                label: 'State',
                                hint: 'Maharashtra',
                                controller: _state,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                          ],
                        ),
                        _Field(
                          label: 'PIN Code',
                          hint: '411001',
                          controller: _zip,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return null;
                            return value.length < 6
                                ? 'Enter a valid 6-digit PIN'
                                : null;
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 96,
              width: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onTap,
          child: const Text('Change Photo'),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.navy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.isLast = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            textInputAction: isLast
                ? TextInputAction.done
                : TextInputAction.next,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.navy, width: 1.4),
              errorBorder: _border(AppColors.danger),
              focusedErrorBorder: _border(AppColors.danger, width: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
