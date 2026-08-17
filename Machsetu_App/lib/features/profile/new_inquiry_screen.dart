import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/api_client.dart';
import '../../core/services/session_store.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../product/data/product.dart';
import '../sell/widgets/sell_widgets.dart';

/// What the RFQ form opens with when it is raised from a product page.
class InquiryArgs {
  const InquiryArgs({
    this.machine = '',
    this.brand = '',
    this.category = '',
    this.image,
    this.productId,
  });

  /// Pre-fills the form from the machine the buyer was looking at.
  factory InquiryArgs.fromProduct(Product product) => InquiryArgs(
    machine: product.title,
    brand: product.brand,
    category: product.equipmentType,
    image: product.images.isEmpty ? null : product.images.first,
  );

  final String machine;
  final String brand;
  final String category;
  final String? image;
  final String? productId;
}

/// Request for quotation raised by a buyer.
///
/// Lands on the sourcing desk in the admin panel and shows up under
/// My Inquiries the moment it is sent.
class NewInquiryScreen extends StatefulWidget {
  const NewInquiryScreen({super.key, this.args});

  final InquiryArgs? args;

  @override
  State<NewInquiryScreen> createState() => _NewInquiryScreenState();
}

class _NewInquiryScreenState extends State<NewInquiryScreen> {
  final _machine = TextEditingController();
  final _brand = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _budget = TextEditingController();
  final _specs = TextEditingController();
  final _city = TextEditingController();
  final _note = TextEditingController();

  final _settings = SettingsService.instance;

  String? _category;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final args = widget.args;
    if (args != null) {
      _machine.text = args.machine;
      _brand.text = args.brand;
      _category = args.category.isEmpty ? null : args.category;
    }
    _settings.addListener(_onSettings);
    _settings.load();
    _prefillBuyer();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    for (final c in [
      _machine,
      _brand,
      _quantity,
      _budget,
      _specs,
      _city,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSettings() {
    if (mounted) setState(() {});
  }

  /// Delivery city defaults to whatever is on the buyer's profile.
  Future<void> _prefillBuyer() async {
    final user = await SessionStore.instance.user();
    if (!mounted || _city.text.isNotEmpty) return;
    final city = [user.city, user.state].where((v) => v.isNotEmpty).join(', ');
    if (city.isNotEmpty) setState(() => _city.text = city);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_machine.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tell us which machine you need')),
      );
      return;
    }

    setState(() => _sending = true);

    final token = await SessionStore.instance.token();
    if (token == null) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to raise an inquiry')),
      );
      return;
    }

    final result = await ApiClient.instance.post(
      '/api/inquiries',
      token: token,
      body: {
        'machine': _machine.text.trim(),
        'brand': _brand.text.trim(),
        'category': _category ?? '',
        'quantity': _quantity.text.trim(),
        'budget': _budget.text.trim(),
        'city': _city.text.trim(),
        'note': _note.text.trim(),
        'image': widget.args?.image,
        'productId': widget.args?.productId,
        'specs': _specs.text
            .split(RegExp(r'[\n,]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      },
    );

    if (!mounted) return;
    setState(() => _sending = false);

    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Could not send the inquiry')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Inquiry ${result.data['reference']} sent to the sourcing desk',
        ),
      ),
    );
    Navigator.of(context).pop(true);
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
        title: const Text(
          'New Inquiry',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const Text(
              'Tell the sourcing desk what you need and a broker will come '
              'back with a quote.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            SellCard(
              icon: Icons.precision_manufacturing,
              title: 'Machine Requirement',
              children: [
                SellField(
                  label: 'Machine / Model',
                  hint: 'Haas VF-2SS',
                  controller: _machine,
                  textCapitalization: TextCapitalization.words,
                ),
                SellField(
                  label: 'Preferred Brand',
                  hint: 'Any brand is fine',
                  controller: _brand,
                  textCapitalization: TextCapitalization.words,
                ),
                SellDropdown(
                  label: 'Category',
                  hint: 'Select a category',
                  value: _category,
                  options: _settings.categories,
                  onChanged: (value) => setState(() => _category = value),
                ),
                SellField(
                  label: 'Quantity',
                  hint: '1',
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SellField(
                  label: 'Required Specifications',
                  hint: 'Travel 650mm, 12,000 RPM, Fanuc control',
                  controller: _specs,
                  maxLines: 3,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            SellCard(
              icon: Icons.request_quote_outlined,
              title: 'Commercials & Delivery',
              children: [
                SellField(
                  label: 'Target Budget (₹)',
                  hint: '7500000',
                  controller: _budget,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SellField(
                  label: 'Delivery City',
                  hint: 'Pune, Maharashtra',
                  controller: _city,
                  textCapitalization: TextCapitalization.words,
                ),
                SellField(
                  label: 'Notes for the Broker',
                  hint: 'Timeline, installation needs, inspection window…',
                  controller: _note,
                  maxLines: 4,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 22),

            PrimaryButton(
              label: 'Send Inquiry',
              loading: _sending,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'A broker responds within 24 hours on business days.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
