import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettings);
    _settings.load();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    super.dispose();
  }

  void _onSettings() {
    if (mounted) setState(() {});
  }

  /// Whatever the desk has published, falling back to the bundled copy.
  List<(String, String)> get _faqs {
    final published = _settings.support.faqs;
    if (published.isEmpty) return _bundledFaqs;
    return [for (final f in published) (f.question, f.answer)];
  }

  static const List<(String, String)> _bundledFaqs = [
    (
      'How is a machine verified before listing?',
      'Every unit passes a 42-point technical audit covering spindle hours, '
          'geometric accuracy, control health and maintenance records. The '
          'audit report is attached to the listing under Technical Documents.',
    ),
    (
      'When is payment released to the seller?',
      'Funds sit in Global Industrial Escrow until you confirm the machine '
          'matches the audit on arrival. Release happens within 48 hours of '
          'your inspection sign-off.',
    ),
    (
      'Who arranges transport and installation?',
      'MachSetu assigns a logistics partner based on the machine footprint '
          'and your site access. Rigging, insurance and commissioning can be '
          'bundled into the quote — ask your broker.',
    ),
    (
      'Can I inspect a machine before buying?',
      'Yes. Request a technical audit from any listing and we will schedule a '
          'supervised inspection at the seller site, or arrange a video walk '
          'through with the operator.',
    ),
    (
      'What happens after I place an inquiry?',
      'A procurement officer reviews your specification within 24 hours, '
          'confirms availability and lead time, then sends a firm quote. You '
          'can track every milestone from the Orders tab.',
    ),
  ];

  void _todo(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — coming soon')));
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
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reach a procurement specialist, or browse answers to the '
            'questions buyers ask most.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ContactTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'Live Chat',
                  detail: 'Avg. 2 min',
                  onTap: () => _todo(context, 'Live chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactTile(
                  icon: Icons.call_outlined,
                  label: 'Call Us',
                  detail: _settings.support.phone,
                  onTap: () => _todo(context, 'Call support'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactTile(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  detail: _settings.support.email,
                  onTap: () => _todo(context, 'Email support'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'FREQUENTLY ASKED',
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: 1.3,
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
                for (var i = 0; i < _faqs.length; i++)
                  Column(
                    children: [
                      Theme(
                        // Removes the default expansion tile divider lines so
                        // the card keeps one continuous border.
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          iconColor: AppColors.accent,
                          collapsedIconColor: AppColors.textMuted,
                          title: Text(
                            _faqs[i].$1,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _faqs[i].$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i != _faqs.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Still stuck?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Raise a technical support ticket and an engineer will pick '
                  'it up within one business day.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: AppColors.steelLight,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => _todo(context, 'Support ticket'),
                  icon: const Icon(
                    Icons.confirmation_number_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Raise a Ticket',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Support hours: ${_settings.support.hours}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: AppColors.brandBlue),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
