import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/catalogue_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import '../product/data/product.dart';
import 'data/machines.dart';
import 'widgets/machine_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _category = 0;
  final _search = TextEditingController();
  final _catalogue = CatalogueService.instance;
  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    _catalogue.addListener(_onCatalogue);
    _settings.addListener(_onCatalogue);
    _catalogue.load();
    _settings.load();
  }

  @override
  void dispose() {
    _catalogue.removeListener(_onCatalogue);
    _settings.removeListener(_onCatalogue);
    _search.dispose();
    super.dispose();
  }

  void _onCatalogue() {
    if (mounted) setState(() {});
  }

  void _todo(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  void _openProduct(Machine machine) {
    Navigator.of(context).pushNamed(
      AppRoutes.product,
      arguments: ProductCatalog.fromMachine(machine),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chips come from the admin panel's Settings page; "All" is always first.
    final chips = _settings.categoryChips;
    final selected = _category.clamp(0, chips.length - 1);
    final featured = _catalogue.forCategory(chips[selected].$2);

    return Scaffold(
      appBar: const MachSetuAppBar(),
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: () async {
          await Future.wait([
            _catalogue.load(force: true),
            _settings.load(force: true),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const Text(
              'INDUSTRIAL INTELLIGENCE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Welcome, Industrial Partner',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 16),
            _SearchBar(controller: _search, onFilter: () => _todo('Filters')),
            const SizedBox(height: 18),
            _PromoCarousel(
              slides: _settings.heroSlides,
              onExplore: () =>
                  Navigator.of(context).pushNamed(AppRoutes.machines),
            ),
            const SizedBox(height: 22),
            const _SectionLabel('ACTIVE CATEGORIES'),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final (icon, label) = chips[index];
                  final isSelected = index == selected;
                  return GestureDetector(
                    onTap: () => setState(() => _category = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navy : AppColors.surface,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: isSelected ? AppColors.navy : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.navy,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: selected == 0 ? 'Featured Machines' : chips[selected].$2,
              action: 'View All Manifests →',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.machines),
            ),
            const SizedBox(height: 4),
            Text(
              '${featured.length} '
              '${featured.length == 1 ? 'machine' : 'machines'} available',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            for (final machine in featured) ...[
              FeaturedMachineCard(
                machine: machine,
                onTap: () => _openProduct(machine),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Added Units',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '12 NEW TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _catalogue.recent.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final machine = _catalogue.recent[index];
                return CompactMachineCard(
                  machine: machine,
                  onTap: () => _openProduct(machine),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onFilter});

  final TextEditingController controller;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search machines, specs, or serial',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune, size: 20),
          onPressed: onFilter,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.4),
        ),
      ),
    );
  }
}

/// Home banner that cycles through the slides set in the admin panel.
///
/// Auto-play pauses while the buyer is swiping and picks up again a few
/// seconds after they let go, matching the product page's hero.
class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({required this.slides, required this.onExplore});

  final List<HeroContent> slides;
  final VoidCallback onExplore;

  static const Duration interval = Duration(seconds: 5);

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  // Every slide is the same size, so the height has to hold the longest copy
  // the desk might type in Settings. The text below is clamped to match.
  static const double _height = 280;

  final _controller = PageController();
  Timer? _timer;
  Timer? _resume;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant _PromoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The desk may have added or removed a slide since the last load.
    if (oldWidget.slides.length != widget.slides.length) {
      if (_index >= widget.slides.length && _controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resume?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;

    _timer = Timer.periodic(_PromoCarousel.interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % widget.slides.length,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
    _resume?.cancel();
    _resume = Timer(const Duration(seconds: 8), _startAutoPlay);
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides.isEmpty
        ? const [HeroContent.fallback]
        : widget.slides;

    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) _pauseAutoPlay();
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) => _PromoBanner(
                  hero: slides[index],
                  onExplore: widget.onExplore,
                ),
              ),
            ),
          ),
          if (slides.length > 1)
            Positioned(
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(left: 5),
                      height: 6,
                      width: i == _index ? 18 : 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(3),
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.hero, required this.onExplore});

  final HeroContent hero;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.bannerGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Workshop photo sits behind the copy; the scrim keeps the text
          // legible no matter how busy the shot is.
          Positioned.fill(
            child: AppImage(
              hero.image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.navyDark.withValues(alpha: 0.97),
                    AppColors.navyDark.withValues(alpha: 0.80),
                    AppColors.navyDeep.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    hero.badge,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mastering Precision,\nMarket-Ready.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hero.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onExplore,
                  child: Text(
                    hero.ctaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}
