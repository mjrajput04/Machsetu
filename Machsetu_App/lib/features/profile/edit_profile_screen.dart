import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/services/upload_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

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
    for (final c in [_name, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    // Fresh from the server, so the form never opens on stale values.
    final user = await SessionStore.instance.user(refresh: true);
    if (!mounted) return;
    setState(() {
      _name.text = user.name;
      _email.text = user.email;
      _phone.text = user.phone;
      _avatar = user.avatar;
      _loading = false;
    });
  }

  /// Uploaded photo path, empty when the account has none.
  String _avatar = '';

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    // Only the fields this form owns are sent. Email is read-only and is
    // echoed back unchanged so the API keeps the account key stable.
    await SessionStore.instance.saveProfile(
      SessionUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        avatar: _avatar,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
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
              (Icons.photo_camera_outlined, 'Take a photo', ImageSource.camera),
              (
                Icons.photo_library_outlined,
                'Choose from gallery',
                ImageSource.gallery,
              ),
              (Icons.delete_outline, 'Remove photo', null),
            ])
              ListTile(
                leading: Icon(option.$1, size: 21, color: AppColors.brandBlue),
                title: Text(option.$2),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  final source = option.$3;
                  if (source == null) {
                    setState(() => _avatar = '');
                    return;
                  }
                  _uploadPhoto(source);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Sends the picked photo to the panel and keeps the returned path.
  Future<void> _uploadPhoto(ImageSource source) async {
    setState(() => _uploadingPhoto = true);
    final url = await UploadService.instance.pickOneAndUpload(source: source);
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = false;
      if (url != null) _avatar = url;
    });
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload that photo')),
      );
    }
  }

  bool _uploadingPhoto = false;

  String get _initials {
    final parts = _name.text
        .trim()
        .split(RegExp(r'\s+'))
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
                        photo: _avatar,
                        busy: _uploadingPhoto,
                        onTap: _changePhoto,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _Group(
                      icon: Icons.person_outline,
                      title: 'Your Details',
                      children: [
                        _Field(
                          label: 'Full Name',
                          hint: 'Your name',
                          controller: _name,
                          validator: Validators.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _Field(
                          label: 'Email Address',
                          hint: 'you@company.com',
                          controller: _email,
                          readOnly: true,
                          note:
                              'Your email is your login and cannot be '
                              'changed here.',
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
                    // Delivery sites live on their own page — a user can have
                    // several, which a single set of fields cannot express.
                    _AddressesLink(
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.myAddresses),
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
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
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
  const _AvatarPicker({
    required this.initials,
    required this.photo,
    required this.busy,
    required this.onTap,
  });

  final String initials;
  final String photo;
  final bool busy;
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
              clipBehavior: Clip.antiAlias,
              child: busy
                  ? const SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : photo.isNotEmpty
                  ? AppImage(photo, fit: BoxFit.cover, height: 96, width: 96)
                  : Text(
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
        TextButton(onPressed: onTap, child: const Text('Change Photo')),
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
    this.readOnly = false,
    this.note,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool isLast;

  /// Shown but not editable — e.g. the email, which is the account key.
  final bool readOnly;

  /// Small caption under the field explaining why it is locked.
  final String? note;

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
            readOnly: readOnly,
            enableInteractiveSelection: !readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            textInputAction: isLast
                ? TextInputAction.done
                : TextInputAction.next,
            style: TextStyle(
              fontSize: 14.5,
              color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: readOnly
                  ? const Icon(
                      Icons.lock_outline,
                      size: 17,
                      color: AppColors.textMuted,
                    )
                  : null,
              hintStyle: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: readOnly ? AppColors.fieldFill : AppColors.surface,
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
          if (note != null) ...[
            const SizedBox(height: 5),
            Text(
              note!,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
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

/// Sends the user to the addresses page — they can save more than one, so the
/// profile form deliberately does not hold a single address.
class _AddressesLink extends StatelessWidget {
  const _AddressesLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Addresses',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Manage your delivery and installation sites',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
