import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import 'data/sell_store.dart';

/// Confirmation after a machine is submitted, with a timeline alternative.
class SubmissionStatusScreen extends StatefulWidget {
  const SubmissionStatusScreen({super.key, required this.listing});

  final SellListing listing;

  @override
  State<SubmissionStatusScreen> createState() => _SubmissionStatusScreenState();
}

class _SubmissionStatusScreenState extends State<SubmissionStatusScreen> {
  bool _timeline = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final hero = listing.images.isEmpty ? null : listing.images.first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Submission Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(26),
            ),
            // Each half takes an equal share so long labels never overflow.
            child: Row(
              children: [
                Expanded(
                  child: _Segment(
                    label: 'Success View',
                    selected: !_timeline,
                    onTap: () => setState(() => _timeline = false),
                  ),
                ),
                Expanded(
                  child: _Segment(
                    label: 'Timeline View',
                    selected: _timeline,
                    onTap: () => setState(() => _timeline = true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          if (_timeline)
            _TimelineView(listing: listing)
          else
            _SuccessView(listing: listing, hero: hero),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.listingDetails, arguments: listing),
            icon: const Icon(Icons.track_changes, size: 20),
            label: const Text(
              'Track Submission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              foregroundColor: AppColors.navy,
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.myListings),
            icon: const Icon(Icons.inventory_2_outlined, size: 19),
            label: const Text(
              'View My Listings',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.listing, required this.hero});

  final SellListing listing;
  final String? hero;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 210,
            width: double.infinity,
            child: hero == null
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.machineGradient,
                    ),
                    child: Icon(
                      listing.icon,
                      size: 72,
                      color: AppColors.navy.withValues(alpha: 0.35),
                    ),
                  )
                : AppImage(
                    hero!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.steelBright),
                  ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Machine Submitted Successfully',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your machine has been submitted for verification.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Current Status: Pending Review',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Our team will review your machine details within 24–48 '
                'hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Reference: ${listing.reference}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.listing});

  final SellListing listing;

  @override
  Widget build(BuildContext context) {
    final events = listing.timeline;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reference ${listing.reference}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < events.length; i++)
            ListingTimelineRow(
              event: events[i],
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}

/// Shared between the submission timeline and the listing detail page.
class ListingTimelineRow extends StatelessWidget {
  const ListingTimelineRow({
    super.key,
    required this.event,
    required this.isLast,
  });

  final ListingEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final reached = event.done || event.current;
    final color = event.current
        ? AppColors.accent
        : event.done
        ? AppColors.navy
        : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: reached ? color : AppColors.scaffold,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reached ? color : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  event.icon,
                  size: 15,
                  color: reached ? Colors.white : AppColors.textMuted,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.3,
                      fontWeight: reached ? FontWeight.w800 : FontWeight.w500,
                      color: reached ? color : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.detail,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: reached
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
