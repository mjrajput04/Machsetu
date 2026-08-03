import 'package:flutter/material.dart';

import '../../core/services/shell_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../cart/data/cart_store.dart';
import '../home/data/machines.dart';
import 'data/product.dart';
import 'widgets/product_hero.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  final _specsKey = GlobalKey();
  final _overviewKey = GlobalKey();
  final _documentsKey = GlobalKey();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Tabs jump to their section rather than swapping the body, so the whole
  /// sheet stays one continuous scroll like the design.
  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    final key = switch (_tabs.index) {
      0 => _specsKey,
      1 => _overviewKey,
      _ => _documentsKey,
    };
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  void _todo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  /// Unwinds every pushed product page and lands on the shell's Cart tab.
  void _openCart() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).popUntil((route) => route.isFirst);
    ShellTabs.go(ShellTabs.cart);
  }

  void _addToCart() {
    CartStore.instance.add(widget.product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${widget.product.title} added to cart'),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: AppColors.accentGlow,
            onPressed: _openCart,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: ProductHero(
              images: product.images,
              icon: product.icon,
              onBack: () => Navigator.of(context).pop(),
              onShare: () => _todo('Share'),
              onSave: () => _todo('Save'),
            ),
          ),
          SliverToBoxAdapter(child: _Header(product: product)),
          SliverToBoxAdapter(
            child: _SectionTabs(controller: _tabs),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpecsSection(key: _specsKey, product: product),
                  const SizedBox(height: 32),
                  _OverviewSection(key: _overviewKey, product: product),
                  const SizedBox(height: 32),
                  _DocumentsSection(
                    key: _documentsKey,
                    product: product,
                    onDownload: (title) => _todo(title),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SimilarMachines(
              onViewAll: () => _todo('Similar machines'),
              onTap: (machine) => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProductDetailScreen(
                    product: ProductCatalog.from(
                      title: machine.title,
                      brand: machine.subtitle,
                      price: machine.price,
                      image: machine.image,
                      icon: machine.icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        onAddToCart: _addToCart,
        onInquiry: () => _todo('Place inquiry'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Pulled up so the sheet overlaps the hero like the design.
      transform: Matrix4.translationValues(0, -22, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              product.series,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'Brand: '),
                TextSpan(
                  text: product.brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.price,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '+ ${product.priceNote}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: TabBar(
          controller: controller,
          labelColor: AppColors.brandBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Specifications'),
            Tab(text: 'Description'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
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
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.brandBlue,
      ),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  const _SpecsSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Technical Specifications'),
        const SizedBox(height: 16),
        for (final spec in product.heroSpecs) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(spec.icon, size: 20, color: AppColors.brandBlue),
                const SizedBox(height: 12),
                Text(
                  spec.label,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  spec.value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < product.detailPairs.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _Pair(pair: product.detailPairs[i])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < product.detailPairs.length
                          ? _Pair(pair: product.detailPairs[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Pair extends StatelessWidget {
  const _Pair({required this.pair});

  final ProductDetailPair pair;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pair.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pair.value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: pair.highlight ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Overview'),
        const SizedBox(height: 14),
        for (final paragraph in product.overview) ...[
          Text(
            paragraph,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 2),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final tag in product.tags)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.scaffold,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MACHINE DETAILS: STRUCTURAL INTEGRITY',
                style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              Icon(
                Icons.view_in_ar_outlined,
                size: 46,
                color: AppColors.brandBlue.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 10),
              const Text(
                'Structural schematic',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    super.key,
    required this.product,
    required this.onDownload,
  });

  final Product product;
  final ValueChanged<String> onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('Technical Documents'),
        const SizedBox(height: 14),
        for (final doc in product.documents) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: doc.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(doc.icon, size: 20, color: doc.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doc.meta,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onDownload(doc.title),
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SimilarMachines extends StatelessWidget {
  const _SimilarMachines({required this.onViewAll, required this.onTap});

  final VoidCallback onViewAll;
  final ValueChanged<Machine> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeading('Similar Machines'),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All  →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MachineData.recent.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final machine = MachineData.recent[index];
              return _SimilarCard(
                machine: machine,
                isNew: index == 0,
                onTap: () => onTap(machine),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({
    required this.machine,
    required this.isNew,
    required this.onTap,
  });

  final Machine machine;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = machine.image;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 118,
                  width: double.infinity,
                  child: image == null
                      ? Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.machineGradient,
                          ),
                        )
                      : Image.asset(image, fit: BoxFit.cover),
                ),
                if (isNew)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.subtitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    machine.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onAddToCart, required this.onInquiry});

  final VoidCallback onAddToCart;
  final VoidCallback onInquiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.brandBlue,
                    side: const BorderSide(color: AppColors.border),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onAddToCart,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Add to Cart',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(50),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onInquiry,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt, size: 19),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'PLACE INQUIRY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
