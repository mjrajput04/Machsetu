import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/catalogue_service.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/shell_tabs.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import '../product/data/product.dart';
import 'data/recent_searches.dart';
import 'data/search_results.dart';
import '../../core/services/machine_filter.dart';
import '../../core/widgets/filter_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Starts empty: the box now really filters, so a canned query would hide
  // most of the catalogue the moment the tab opens.
  final _query = TextEditingController();

  /// Live filter — the query box feeds it, the sheet edits the rest.
  MachineFilter _filter = const MachineFilter();
  final _focus = FocusNode();
  final _catalogue = CatalogueService.instance;
  final _recents = RecentSearchStore.instance;

  /// The recents panel only opens while the user is actually searching.
  bool _searching = false;

  /// Falls back to the design's placeholder until a registered name is stored.
  String _initials = 'JD';

  @override
  void initState() {
    super.initState();
    // The results header echoes the query, so rebuild as the user types.
    _query.addListener(() => setState(() {}));
    _catalogue.addListener(_onCatalogue);
    _catalogue.load();
    _recents.addListener(_onCatalogue);
    _recents.load();
    _focus.addListener(_onFocus);
    _loadUser();
  }

  /// Tapping into the box opens the recents; leaving it closes them again.
  void _onFocus() {
    if (!mounted) return;
    setState(() => _searching = _focus.hasFocus);
    // Leaving the box is the moment a query becomes a real search.
    if (!_focus.hasFocus) _remember();
  }

  /// Files the current query in the recent list.
  void _remember() {
    final term = _query.text.trim();
    if (term.isNotEmpty) _recents.record(term);
  }

  void _onCatalogue() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUser() async {
    final user = await SessionStore.instance.user();
    if (!mounted || user.initials.isEmpty) return;
    setState(() => _initials = user.initials);
  }

  /// Live listings carry the full record; bundled ones keep the demo shape.
  Product _detailFor(SearchListing listing) {
    final machine = _catalogue.byTitle(listing.title);
    if (machine != null) return ProductCatalog.fromMachine(machine);
    return ProductCatalog.from(
      title: listing.title,
      brand: listing.brand,
      price: listing.price,
      // Subtitle is "<type> • <year>" — the type is enough here.
      equipmentType: listing.subtitle.split('•').first.trim(),
      image: listing.image,
      icon: listing.icon,
    );
  }

  @override
  void dispose() {
    _catalogue.removeListener(_onCatalogue);
    _recents.removeListener(_onCatalogue);
    _focus.removeListener(_onFocus);
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _applyRecent(String term) {
    _query
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _recents.record(term);
    _focus.unfocus();
    setState(() => _searching = false);
  }

  Future<void> _openFilters() async {
    final updated = await showFilterSheet(
      context: context,
      current: _filter.copyWith(query: _query.text.trim()),
      machines: _catalogue.all,
    );
    if (updated != null && mounted) setState(() => _filter = updated);
  }

  Future<void> _openSort() async {
    final sort = await showSortSheet(context: context, current: _filter.sort);
    if (sort != null && mounted) {
      setState(() => _filter = _filter.copyWith(sort: sort));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim();
    // The typed query is part of the filter, so one pipeline drives the list.
    final machines = _filter.copyWith(query: query).apply(_catalogue.all);
    final results = machines.map(_catalogue.searchListingFor).toList();

    return Scaffold(
      appBar: MachSetuAppBar(
        onAvatarTap: () => ShellTabs.go(ShellTabs.profile),
        showAvatar: true,
        initials: _initials,
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Home's FAB is alive in the same IndexedStack, so both need
        // distinct hero tags or Navigator throws on a duplicate tag.
        heroTag: 'search-filters-fab',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: _openFilters,
        icon: const Icon(Icons.filter_list, size: 20),
        label: Text(
          _filter.activeCount == 0
              ? 'Filters'
              : 'Filters (${_filter.activeCount})',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _SearchPanel(
            controller: _query,
            focusNode: _focus,
            // Recents belong to the act of searching, not to the results.
            showRecents: _searching,
            recents: _recents.terms,
            onClear: () => _query.clear(),
            onSubmit: (_) {
              _remember();
              _focus.unfocus();
            },
            onRecentTap: _applyRecent,
            onRecentRemove: _recents.remove,
            onClearRecents: _recents.clear,
          ),
          const SizedBox(height: 20),
          _ResultsHeader(
            query: query,
            count: results.length,
            sortLabel: _filter.sort.label,
            onSortTap: _openSort,
          ),
          const SizedBox(height: 14),
          if (results.isEmpty)
            const _NoResults()
          else
            for (final listing in results) ...[
              SearchResultCard(
                listing: listing,
                onViewDetails: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.product, arguments: _detailFor(listing)),
              ),
              const SizedBox(height: 16),
            ],
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
    required this.showRecents,
    required this.recents,
    required this.onClear,
    required this.onSubmit,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearRecents,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// True while the box has focus — the only time recents are shown.
  final bool showRecents;
  final List<String> recents;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearRecents;

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
            onSubmitted: onSubmit,
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
          // Nothing below the box until the user is actually searching, and
          // nothing at all until they have searched at least once.
          if (showRecents && recents.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'RECENT SEARCHES',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClearRecents,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final term in recents)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _RecentChip(
                    label: term,
                    onTap: () => onRecentTap(term),
                    onRemove: () => onRecentRemove(term),
                  ),
                ),
              ),
          ],
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
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 15, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.query,
    required this.count,
    required this.sortLabel,
    required this.onSortTap,
  });

  final String query;
  final int count;
  final String sortLabel;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            query.isEmpty
                ? '$count result${count == 1 ? '' : 's'}'
                : '$count result${count == 1 ? '' : 's'} for "$query"',
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
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                sortLabel,
                style: const TextStyle(
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
                      color: _saved
                          ? AppColors.accent
                          : AppColors.textSecondary,
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
                const SizedBox(height: 6),
                Text(
                  listing.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
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
      child: path == null || path.trim().isEmpty
          ? _fallback()
          : AppImage(
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
class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 42, color: AppColors.textMuted),
          const SizedBox(height: 14),
          const Text(
            'No machines match',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term, or clear a filter or two.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
