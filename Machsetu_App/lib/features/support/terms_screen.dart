import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const String updated = 'Last updated: 1 August 2026';

  static const List<(String, List<String>)> _sections = [
    (
      '1. Scope of the Marketplace',
      [
        'MachSetu operates a business-to-business marketplace connecting '
            'buyers and sellers of CNC, VMC and allied industrial machinery '
            'in India. MachSetu facilitates discovery, technical verification, '
            'escrow and logistics; it is not the manufacturer or owner of the '
            'machines listed.',
        'Accounts are issued to registered business entities. You confirm you '
            'are authorised to transact on behalf of the organisation named '
            'during registration.',
      ],
    ),
    (
      '2. Listings and Technical Audits',
      [
        'Sellers are responsible for the accuracy of specifications, spindle '
            'hours and maintenance history submitted with a listing. Audit '
            'reports published on a listing reflect the condition observed on '
            'the audit date and do not constitute a warranty of future '
            'performance.',
        'Where a discrepancy between the audit report and the delivered '
            'machine is established, the escrow release is suspended pending '
            'resolution.',
      ],
    ),
    (
      '3. Inquiries, Quotes and Pricing',
      [
        'Prices shown on listings are indicative asking prices. A binding '
            'price is established only in a written quote issued after the '
            'technical review. Taxes, freight, rigging, insurance and '
            'installation are quoted separately unless expressly bundled.',
        'GST is applied at the prevailing statutory rate on the taxable value '
            'of goods and services in your order.',
      ],
    ),
    (
      '4. Escrow and Payment',
      [
        'Funds are held by the appointed escrow provider until you confirm '
            'that the machine matches the audit on arrival, or until the '
            'inspection window lapses. Release is initiated within 48 hours '
            'of sign-off.',
        'Refunds arising from a confirmed material misdescription are '
            'processed to the originating account within 14 business days.',
      ],
    ),
    (
      '5. Delivery, Risk and Title',
      [
        'Risk passes to the buyer on delivery at the nominated site unless '
            'the quote states otherwise. Title passes on full settlement of '
            'the invoice, including all freight and statutory dues.',
        'Delivery windows are estimates. MachSetu is not liable for delays '
            'caused by force majeure, port congestion or regulatory holds.',
      ],
    ),
    (
      '6. Cancellation',
      [
        'An inquiry may be withdrawn at no cost before a firm quote is '
            'accepted. After acceptance, cancellation charges may apply to '
            'cover rigging, transport and restocking already committed.',
      ],
    ),
    (
      '7. Privacy',
      [
        'We collect the account, company and delivery details you provide in '
            'order to operate the marketplace, and share them with sellers, '
            'logistics partners and the escrow provider only to the extent '
            'needed to complete your transaction.',
        'We do not sell personal data. You may request export or deletion of '
            'your account data through Help & Support.',
      ],
    ),
    (
      '8. Liability',
      [
        'To the extent permitted by law, MachSetu\'s aggregate liability in '
            'connection with any transaction is limited to the platform fees '
            'received for that transaction. Nothing in these terms limits '
            'liability for fraud or for death or personal injury caused by '
            'negligence.',
      ],
    ),
    (
      '9. Governing Law',
      [
        'These terms are governed by the laws of India. Disputes are subject '
            'to the exclusive jurisdiction of the courts at Ahmedabad, '
            'Gujarat.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Terms & Conditions'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const Text(
            'Terms of Trade',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            updated,
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.accent, width: 4),
              ),
            ),
            child: const Text(
              'This is a plain-language summary for the prototype. Have your '
              'legal counsel review and replace this content before launch.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          for (final section in _sections) ...[
            Text(
              section.$1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 10),
            for (final paragraph in section.$2) ...[
              Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Questions about these terms? Reach us through Help & Support or '
            'write to legal@machsetu.in.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
