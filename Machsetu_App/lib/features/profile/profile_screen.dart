import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import 'data/profile_data.dart';

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
    final user = await SessionStore.instance.user();
    if (!mounted) return;
    setState(() => _user = user);
  }

  void _todo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  /// Confirms before dropping the session — logging out is easy to hit by
  /// accident and costs the user a full sign-in.
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
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
        : ProfileData.fallbackName;
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
            role: (_user?.role.isNotEmpty ?? false)
                ? _user!.role
                : ProfileData.role,
            company: (_user?.company.isNotEmpty ?? false)
                ? _user!.company
                : ProfileData.company,
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
                  icon: Icons.badge_outlined,
                  title: 'Edit Profile',
                  detail: 'Update personal details, company info, and contact '
                      'preferences',
                  onTap: () async {
                    final saved = await Navigator.of(context)
                        .pushNamed<Object?>(AppRoutes.editProfile);
                    // Pull the freshly saved details back into the header.
                    if (saved == true) await _load();
                  },
                ),
                _SettingRow(
                  icon: Icons.description_outlined,
                  title: 'My Inquiries',
                  detail: 'Track RFQs, active quotes, and technical '
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
                  detail: 'Knowledge base, technical support tickets, and '
                      'live chat',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.helpSupport),
                ),
                _SettingRow(
                  icon: Icons.gavel_outlined,
                  title: 'Terms & Conditions',
                  detail: 'Terms of trade, privacy policy and escrow '
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
          const SizedBox(height: 26),
          const _SectionHeading('Active Status'),
          const SizedBox(height: 12),
          const _ActiveOrdersCard(),
          const SizedBox(height: 22),
          const Text(
            'RECENT LOGS',
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
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
                for (var i = 0; i < ProfileData.logs.length; i++)
                  _LogRow(
                    log: ProfileData.logs[i],
                    isLast: i == ProfileData.logs.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _UpgradeBanner(onTap: () => _todo('Pro+ upgrade')),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.initials,
    required this.role,
    required this.company,
  });

  final String name;
  final String initials;
  final String role;
  final String company;

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
          child: Text(
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
        const SizedBox(height: 5),
        Text(
          role,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          company,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            ProfileData.memberId,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 14, color: AppColors.accent),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                ProfileData.verification,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
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
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  final bool danger;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tint = danger ? AppColors.danger : AppColors.brandBlue;

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
                          color: danger ? AppColors.danger : AppColors.navy,
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

class _ActiveOrdersCard extends StatelessWidget {
  const _ActiveOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: AppColors.bannerGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACTIVE ORDERS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.steelLight,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up,
                size: 19,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '${ProfileData.activeOrders}',
            style: TextStyle(
              fontSize: 38,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            ProfileData.activeOrdersNote,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.steelLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log, required this.isLast});

  final ActivityLog log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: log.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(log.icon, size: 18, color: log.color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      log.detail,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log.stamp,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 63, color: AppColors.border),
      ],
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 118,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/machines/workshop_banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.navy,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.navyDark.withValues(alpha: 0.94),
                    AppColors.navyDeep.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upgrade to Pro+',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get priority dispatch and 24/7 engineering consulting.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
