import 'package:flutter/material.dart';

import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import 'data/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController(text: SearchData.defaultQuery);
  final _focus = FocusNode();

  /// Falls back to the design's placeholder until a registered name is stored.
  String _initials = 'JD';

  @override
  void initState() {
    super.initState();
    // The results header echoes the query, so rebuild as the user types.
    _query.addListener(() => setState(() {}));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionStore.instance.user();
    if (!mounted || user.initials.isEmpty) return;
    setState(() => _initials = user.initials);
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _todo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  void _applyRecent(String term) {
    _query
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim();

    return Scaffold(
      appBar: MachSetuAppBar(
        onNotifications: () => _todo('Notifications'),
        onAvatarTap: () => _todo('Profile'),
        showAvatar: true,
        initials: _initials,
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Home's FAB is alive in the same IndexedStack, so both need
        // distinct hero tags or Navigator throws on a duplicate tag.
        heroTag: 'search-filters-fab',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _todo('Filters'),
        icon: const Icon(Icons.filter_list, size: 20),
        label: const Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _SearchPanel(
            controller: _query,
            focusNode: _focus,
            onClear: () => _query.clear(),
            onRecentTap: _applyRecent,
          ),
          const SizedBox(height: 20),
          _ResultsHeader(
            query: query,
            onSortTap: () => _todo('Sort options'),
          ),
          const SizedBox(height: 14),
          for (final listing in SearchData.results) ...[
            SearchResultCard(
              listing: listing,
              onViewDetails: () => _todo(listing.title),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 4),
          const _RefineHint(),
        ],
      ),
    );
  }
}

/// White panel holding the query field and the recent-search shortcuts.
class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onRecentTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final ValueChanged<String> onRecentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search machines, specs, or serial',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14.5,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onClear,
                    ),
              filled: true,
              fillColor: AppColors.scaffold,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.navy, width: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'RECENT SEARCHES',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          for (final term in SearchData.recentSearches)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _RecentChip(
                  label: term,
                  onTap: () => onRecentTap(term),
                ),
              ),
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.query, required this.onSortTap});

  final String query;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            query.isEmpty
                ? '${SearchData.totalResults} results'
                : '${SearchData.totalResults} results for "$query"',
            style: const TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onSortTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Relevance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.brandBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchResultCard extends StatefulWidget {
  const SearchResultCard({
    super.key,
    required this.listing,
    this.onViewDetails,
  });

  final SearchListing listing;
  final VoidCallback? onViewDetails;

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _ListingPhoto(image: listing.image, icon: listing.icon),
              // Badges hug the top-left corner, so the leading one is clipped
              // by the card's radius exactly like the design.
              Positioned(
                top: 0,
                left: 0,
                child: Row(
                  children: [
                    for (final badge in listing.badges) ...[
                      _Badge(badge: badge),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _saved = !_saved),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _saved ? Icons.favorite : Icons.favorite_border,
                      size: 17,
                      color: _saved ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final spec in listing.specs)
                      Expanded(child: _SpecColumn(spec: spec)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onViewDetails,
                    child: const Text('View Details'),
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

class _ListingPhoto extends StatelessWidget {
  const _ListingPhoto({required this.image, required this.icon});

  final String? image;
  final IconData icon;

  static const double _height = 160;

  @override
  Widget build(BuildContext context) {
    final path = image;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: path == null
          ? _fallback()
          : Image.asset(
              path,
              height: _height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.machineGradient),
      child: Center(
        child: Icon(
          icon,
          size: _height * 0.34,
          color: AppColors.navy.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.badge});

  final ResultBadge badge;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (badge.tone) {
      BadgeTone.accent => (AppColors.accent, Colors.white),
      BadgeTone.navy => (AppColors.navy, Colors.white),
      BadgeTone.light => (Colors.white, AppColors.navy),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: foreground,
        ),
      ),
    );
  }
}

class _SpecColumn extends StatelessWidget {
  const _SpecColumn({required this.spec});

  final ResultSpec spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spec.label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          spec.value,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}

/// Dashed callout nudging the buyer towards narrowing the result set.
class _RefineHint extends StatelessWidget {
  const _RefineHint();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_outlined,
                size: 22,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Refine filters to see more precise matches for your '
              'requirements.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const double _radius = 14;
  static const double _dash = 6;
  static const double _gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.border;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
