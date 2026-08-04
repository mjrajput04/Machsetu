import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  SecuritySettings _settings = const SecuritySettings(
    twoFactor: false,
    biometrics: false,
    loginAlerts: true,
  );
  bool _loading = true;

  /// Demo session list — replace with the sessions endpoint when it exists.
  final List<_Session> _sessions = [
    const _Session(
      device: 'Android • This device',
      location: 'Pune, Maharashtra',
      lastActive: 'Active now',
      current: true,
    ),
    const _Session(
      device: 'Chrome • Windows 11',
      location: 'Ahmedabad, Gujarat',
      lastActive: '2 hours ago',
    ),
    const _Session(
      device: 'Safari • iPad Pro',
      location: 'Bengaluru, Karnataka',
      lastActive: 'Yesterday',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await SessionStore.instance.security();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _update(SecuritySettings next, String message) async {
    setState(() => _settings = next);
    await SessionStore.instance.saveSecurity(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changePassword() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        // Lifts the sheet above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: const _ChangePasswordSheet(),
      ),
    );

    if (changed != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
  }

  Future<void> _revoke(_Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Sign out this device?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        content: Text(
          '${session.device} in ${session.location} will need to sign in '
          'again.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
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
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _sessions.remove(session));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${session.device} signed out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final others = _sessions.where((s) => !s.current).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Security'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                const Text(
                  'Account Security',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your password, two-factor authentication and the '
                  'devices signed in to this account.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _SecurityScore(settings: _settings),
                const SizedBox(height: 20),
                const _GroupLabel('SIGN-IN'),
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
                      _ActionRow(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        detail: 'Last changed 42 days ago',
                        onTap: _changePassword,
                      ),
                      const Divider(height: 1, indent: 62),
                      _ToggleRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Two-Factor Authentication',
                        detail: 'Require an OTP on every new sign-in',
                        value: _settings.twoFactor,
                        onChanged: (value) => _update(
                          _settings.copyWith(twoFactor: value),
                          value
                              ? 'Two-factor authentication enabled'
                              : 'Two-factor authentication disabled',
                        ),
                      ),
                      const Divider(height: 1, indent: 62),
                      _ToggleRow(
                        icon: Icons.fingerprint,
                        title: 'Biometric Unlock',
                        detail: 'Use fingerprint or face unlock on this device',
                        value: _settings.biometrics,
                        onChanged: (value) => _update(
                          _settings.copyWith(biometrics: value),
                          value
                              ? 'Biometric unlock enabled'
                              : 'Biometric unlock disabled',
                        ),
                      ),
                      const Divider(height: 1, indent: 62),
                      _ToggleRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Login Alerts',
                        detail: 'Email me when a new device signs in',
                        value: _settings.loginAlerts,
                        onChanged: (value) => _update(
                          _settings.copyWith(loginAlerts: value),
                          value ? 'Login alerts on' : 'Login alerts off',
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _GroupLabel('ACTIVE SESSIONS'),
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
                      for (var i = 0; i < _sessions.length; i++) ...[
                        _SessionRow(
                          session: _sessions[i],
                          onRevoke: () => _revoke(_sessions[i]),
                        ),
                        if (i != _sessions.length - 1)
                          const Divider(height: 1, indent: 62),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.danger,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: others.isEmpty
                      ? null
                      : () {
                          setState(
                            () => _sessions.removeWhere((s) => !s.current),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All other devices signed out'),
                            ),
                          );
                        },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    others.isEmpty
                        ? 'No other active devices'
                        : 'Sign Out All Other Devices',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SecurityScore extends StatelessWidget {
  const _SecurityScore({required this.settings});

  final SecuritySettings settings;

  @override
  Widget build(BuildContext context) {
    // Password counts as always-on; the rest are opt-in hardening.
    final enabled = 1 +
        (settings.twoFactor ? 1 : 0) +
        (settings.biometrics ? 1 : 0) +
        (settings.loginAlerts ? 1 : 0);
    final ratio = enabled / 4;
    final (label, color) = switch (enabled) {
      >= 4 => ('Strong', AppColors.success),
      3 => ('Good', AppColors.accent),
      _ => ('Needs attention', AppColors.danger),
    };

    return Container(
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
                  'SECURITY STRENGTH',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.steelLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$enabled of 4 protections enabled',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.steelLight,
            ),
          ),
        ],
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
      text,
      style: const TextStyle(
        fontSize: 11.5,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
        child: Row(
          children: [
            _IconTile(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 19,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          _IconTile(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 19, color: AppColors.brandBlue),
    );
  }
}

class _Session {
  const _Session({
    required this.device,
    required this.location,
    required this.lastActive,
    this.current = false,
  });

  final String device;
  final String location;
  final String lastActive;
  final bool current;
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.onRevoke});

  final _Session session;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: (session.current ? AppColors.success : AppColors.steel)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              session.current ? Icons.smartphone : Icons.devices_other,
              size: 19,
              color: session.current ? AppColors.success : AppColors.steel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.device,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.location} • ${session.lastActive}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!session.current)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: onRevoke,
              child: const Text('Revoke'),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }
}

/// Password change form, validated locally against the mock auth service.
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final user = await SessionStore.instance.user();
    final result = await AuthService.instance.resetPassword(
      phone: user.phone,
      newPassword: _next.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not update password')),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 18),
            _PasswordField(
              label: 'Current Password',
              controller: _current,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: 'New Password',
              controller: _next,
              validator: (value) {
                final base = Validators.password(value);
                if (base != null) return base;
                return value == _current.text
                    ? 'New password must differ from the current one'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: 'Confirm New Password',
              controller: _confirm,
              validator: Validators.confirmPassword(() => _next.text),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          obscureText: true,
          style: const TextStyle(fontSize: 14.5),
          decoration: InputDecoration(
            hintText: '••••••••',
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
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
