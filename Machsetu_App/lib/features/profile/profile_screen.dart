import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/machsetu_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  /// Clears the session and returns to login — owned by the shell.
  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SessionUser? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Pulled fresh so anything the sourcing desk changed shows up here too.
    final user = await SessionStore.instance.user(refresh: true);
    if (!mounted) return;
    setState(() => _user = user);
  }

  /// Confirms before dropping the session — logging out is easy to hit by
  /// accident and costs the user a full sign-in.
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout,
                size: 20,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Log out?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'You will need to sign in again to access your inquiries, cart and '
          'order history.',
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(110, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final name = (_user?.name.isNotEmpty ?? false)
        ? _user!.name
        : 'MachSetu User';
    final initials = (_user?.initials.isNotEmpty ?? false)
        ? _user!.initials
        : 'MS';

    return Scaffold(
      appBar: MachSetuAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          _Header(
            name: name,
            initials: initials,
            photo: _user?.avatar ?? '',
            email: _user?.email ?? '',
            phone: _user?.phone ?? '',
          ),
          const SizedBox(height: 26),
          const _SectionHeading('Account Settings'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.sell_outlined,
                  title: 'Sell Your Machine',
                  detail:
                      'Your live, pending and sold listings — add a new '
                      'machine from there',
                  highlight: true,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.myListings),
                ),
                _SettingRow(
                  icon: Icons.badge_outlined,
                  title: 'Edit Profile',
                  detail: 'Update your name, mobile number and photo',
                  onTap: () async {
                    final saved = await Navigator.of(
                      context,
                    ).pushNamed<Object?>(AppRoutes.editProfile);
                    // Pull the freshly saved details back into the header.
                    if (saved == true) await _load();
                  },
                ),
                _SettingRow(
                  icon: Icons.location_on_outlined,
                  title: 'My Addresses',
                  detail:
                      'Delivery and installation sites — add, edit or remove '
                      'them',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.myAddresses),
                ),
                _SettingRow(
                  icon: Icons.description_outlined,
                  title: 'My Inquiries',
                  detail:
                      'Track RFQs, active quotes, and technical '
                      'specifications',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.myInquiries),
                ),
                _SettingRow(
                  icon: Icons.shield_outlined,
                  title: 'Security',
                  detail: 'Manage passwords, 2FA, and active session history',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.security),
                ),
                _SettingRow(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  detail:
                      'Knowledge base, technical support tickets, and '
                      'live chat',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.helpSupport),
                ),
                _SettingRow(
                  icon: Icons.gavel_outlined,
                  title: 'Terms & Conditions',
                  detail:
                      'Terms of trade, privacy policy and escrow '
                      'agreement',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.terms),
                ),
                _SettingRow(
                  icon: Icons.logout,
                  title: 'Logout',
                  detail: 'Securely sign out of your professional account',
                  danger: true,
                  isLast: true,
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.initials,
    required this.photo,
    required this.email,
    required this.phone,
  });

  final String name;
  final String initials;

  /// Uploaded profile photo; falls back to the monogram when empty.
  final String photo;
  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 92,
          width: 92,
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
          child: photo.isNotEmpty
              ? AppImage(photo, fit: BoxFit.cover, height: 92, width: 92)
              : Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        if (email.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          _ContactLine(icon: Icons.mail_outline, value: email),
        ],
        if (phone.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          _ContactLine(icon: Icons.phone_iphone, value: phone),
        ],
      ],
    );
  }
}

/// One centred icon + value row under the name.
class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.danger = false,
    this.highlight = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  final bool danger;

  /// Draws the row in accent orange — used for the seller call to action.
  final bool highlight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tint = danger
        ? AppColors.danger
        : highlight
        ? AppColors.accent
        : AppColors.brandBlue;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 19, color: tint),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: danger
                              ? AppColors.danger
                              : highlight
                              ? AppColors.accent
                              : AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detail,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 19,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 65, color: AppColors.border),
      ],
    );
  }
}
