import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/brand_logo.dart';
import '../cart/data/cart_store.dart';
import '../orders/data/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _gstin = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();

  bool _placing = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _company,
      _gstin,
      _street,
      _city,
      _state,
      _zip,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _placing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _placing = false);

    // Snapshot the basket into an order, then hand off to the confirmation.
    final order = OrderStore.instance.place(CartStore.instance);
    CartStore.instance.clear();

    await Navigator.of(context).pushReplacementNamed(
      AppRoutes.orderSuccess,
      arguments: order,
    );
  }

  void _todo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            BrandLogo(size: 28),
            SizedBox(width: 10),
            BrandWordmark(fontSize: 15, letterSpacing: 0.8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: CartStore.instance,
        builder: (context, _) {
          final cart = CartStore.instance;
          if (cart.isEmpty) return const _EmptyCheckout();

          return Form(
            key: _formKey,
            // A lazy ListView would dispose off-screen fields, unregistering
            // them from the Form and letting an empty form validate.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const _SecureBanner(),
                const SizedBox(height: 18),
                _Section(
                  icon: Icons.person_outline,
                  title: 'Customer Details',
                  children: [
                    _Field(
                      label: 'Full Name',
                      hint: 'e.g. Johnathan Miller',
                      controller: _name,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    _Field(
                      label: 'Mobile Number',
                      hint: '+91 98765-43210',
                      controller: _phone,
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  icon: Icons.business_outlined,
                  title: 'Company Information',
                  children: [
                    _Field(
                      label: 'Company Name',
                      hint: 'Apex Manufacturing Ltd.',
                      controller: _company,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Company name is required'
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    _Field(
                      label: 'GST / Tax Identification Number',
                      hint: 'GSTIN-9922883311',
                      controller: _gstin,
                      validator: (v) => (v ?? '').trim().length < 8
                          ? 'Enter a valid GSTIN'
                          : null,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  icon: Icons.place_outlined,
                  title: 'Delivery Address',
                  children: [
                    _Field(
                      label: 'Street Address / Warehouse Unit',
                      hint: 'Plot 44, Industrial Area Phase II',
                      controller: _street,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Delivery address is required'
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'City',
                            hint: 'Pune',
                            controller: _city,
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Required'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _Field(
                            label: 'State/Province',
                            hint: 'Maharashtra',
                            controller: _state,
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? 'Required'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    _Field(
                      label: 'ZIP / Postal Code',
                      hint: '48201',
                      controller: _zip,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (v) => (v ?? '').trim().length < 5
                          ? 'Enter a valid PIN code'
                          : null,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _OrderSummaryCard(
                  placing: _placing,
                  onPlaceOrder: _placeOrder,
                ),
                const SizedBox(height: 18),
                _HelpBox(onContact: () => _todo('Procurement specialist')),
                const SizedBox(height: 22),
                const Text(
                  '© 2026 MachSetu Marketplace. All Rights Reserved.\n'
                  'ISO 27001 Certified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SecureBanner extends StatelessWidget {
  const _SecureBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Secure Checkout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
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
              Icon(icon, size: 20, color: AppColors.navy),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
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
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
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

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.placing, required this.onPlaceOrder});

  final bool placing;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.navy,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Reference: ${cart.orderReference}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGlow,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              children: [
                for (final item in cart.items) ...[
                  _LineItem(item: item),
                  const SizedBox(height: 14),
                ],
                const Divider(),
                const SizedBox(height: 10),
                _Row(
                  label: 'Subtotal',
                  value: Rupees.format(cart.subtotal),
                ),
                _Row(
                  label: 'Estimated Freight',
                  value: Rupees.format(cart.freight),
                  accent: true,
                ),
                _Row(
                  label: 'GST (18%)',
                  value: Rupees.format(cart.gst),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 10),
                _Row(
                  label: 'Total Amount',
                  value: Rupees.format(cart.total),
                  emphasise: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: placing ? null : onPlaceOrder,
                  child: placing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 19),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Encrypted B2B Transaction Support',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final image = product.images.isEmpty ? null : product.images.first;
    final tag = product.tags.isEmpty ? null : product.tags.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 48,
            width: 56,
            child: image == null
                ? _fallback(product.icon)
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallback(product.icon),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Qty: ${item.quantity}${tag == null ? '' : ' • $tag'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                Rupees.format(product.amount * item.quantity),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallback(IconData icon) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.machineGradient),
      child: Icon(icon, size: 20, color: AppColors.navy.withValues(alpha: 0.4)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.accent = false,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool accent;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: emphasise ? 14.5 : 13.5,
              fontWeight: emphasise ? FontWeight.w800 : FontWeight.w400,
              color: emphasise
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: emphasise ? 16 : 13.5,
                  fontWeight: FontWeight.w800,
                  color: accent
                      ? AppColors.accent
                      : emphasise
                      ? AppColors.navy
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBox extends StatelessWidget {
  const _HelpBox({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              size: 20,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need help with logistics?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: onContact,
                  child: const Text(
                    'Contact Procurement Specialist',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
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

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Your cart is empty — add a machine before checking out.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
