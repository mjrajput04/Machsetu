import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import 'data/sell_store.dart';

/// Seller inventory with search and state filters.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final _search = TextEditingController();

  /// null is the "All Listings" chip.
  ListingState? _filter;

  static const List<(String, ListingState?)> _filters = [
    ('All Listings', null),
    ('Live', ListingState.live),
    ('Pending Review', ListingState.pendingReview),
    ('Sold', ListingState.sold),
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MachSetuAppBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'my-listings-sell-fab',
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.sellMachine),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: SellStore.instance,
        builder: (context, _) {
          final listings = SellStore.instance.search(
            _search.text,
            state: _filter,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
            children: [
              const Text(
                'My Listings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                style: const TextStyle(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Search my listings...',
                  hintStyle: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _search.clear,
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: _border(AppColors.border),
                  enabledBorder: _border(AppColors.border),
                  focusedBorder: _border(AppColors.navy, width: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final (label, state) = _filters[index];
                    final selected = state == _filter;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = state),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.navy : AppColors.surface,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: selected
                                ? AppColors.navy
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              if (listings.isEmpty)
                _NoListings(searching: _search.text.trim().isNotEmpty)
              else
                for (final listing in listings) ...[
                  _ListingCard(
                    listing: listing,
                    onOpen: () => Navigator.of(context).pushNamed(
                      AppRoutes.listingDetails,
                      arguments: listing,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          );
        },
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

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.onOpen});

  final SellListing listing;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final image = listing.images.isEmpty ? null : listing.images.first;
    final sold = listing.isSold;
    final pending = listing.state == ListingState.pendingReview;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: image == null
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.machineGradient,
                        ),
                        child: Icon(
                          listing.icon,
                          size: 50,
                          color: AppColors.navy.withValues(alpha: 0.35),
                        ),
                      )
                    : ColorFiltered(
                        // Closed and pending listings read as inactive.
                        colorFilter: _saturation(sold || pending ? 0.25 : 1),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: AppColors.steelBright,
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listing.state.icon,
                        size: listing.state == ListingState.live ? 9 : 13,
                        color: listing.state.foreground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        listing.state.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: listing.state.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: sold
                              ? AppColors.textSecondary
                              : AppColors.navy,
                          decoration: sold
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          listing.price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: sold
                                ? AppColors.textSecondary
                                : AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(label: '${listing.year} Model'),
                    _Chip(label: listing.location, icon: Icons.place_outlined),
                    if (listing.category.isNotEmpty)
                      _Chip(label: listing.category),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sold
                            ? 'Sold on ${listing.soldOn ?? listing.submittedOn}'
                            : pending
                            ? listing.submittedOn
                            : '${listing.views} Views',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (pending)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.navy),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onOpen,
                        child: const Text(
                          'Edit Listing',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else if (sold)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onOpen,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          minimumSize: const Size(0, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onOpen,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoListings extends StatelessWidget {
  const _NoListings({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 34,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            searching ? 'No matching listings' : 'No listings yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              searching
                  ? 'Try a different machine, brand or city.'
                  : 'Tap + to submit your first machine for verification.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Saturation filter — 1 leaves the photo untouched, 0 is greyscale.
ColorFilter _saturation(double s) {
  const lumR = 0.2126;
  const lumG = 0.7152;
  const lumB = 0.0722;
  final sr = (1 - s) * lumR;
  final sg = (1 - s) * lumG;
  final sb = (1 - s) * lumB;

  return ColorFilter.matrix([
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}
