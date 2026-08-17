import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import 'data/sell_store.dart';
import 'submission_status_screen.dart';
import 'widgets/sell_widgets.dart';

/// Seller-side view of one listing: photos, specs, progress and documents.
class ListingDetailsScreen extends StatelessWidget {
  const ListingDetailsScreen({super.key, required this.listing});

  final SellListing listing;

  void _todo(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final images = listing.images;
    final hero = images.isEmpty ? null : images.first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Listing Details'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 210,
                width: double.infinity,
                child: hero == null
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.machineGradient,
                        ),
                        child: Icon(
                          listing.icon,
                          size: 66,
                          color: AppColors.navy.withValues(alpha: 0.35),
                        ),
                      )
                    : AppImage(
                        hero,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.steelBright),
                      ),
              ),
              Positioned(
                top: 14,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: listing.state == ListingState.live
                        ? AppColors.accent
                        : listing.state.foreground,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    listing.state == ListingState.live
                        ? 'Live on Marketplace'
                        : listing.state.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (var i = 1; i < images.length && i < 3; i++) ...[
                    Expanded(
                      child: _Thumb(
                        path: images[i],
                        overlay: i == 2 && images.length > 3
                            ? '+${images.length - 3} Photos'
                            : null,
                      ),
                    ),
                    if (i == 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeadCard(listing: listing),
                const SizedBox(height: 16),
                if (listing.machineDetailRows.isNotEmpty) ...[
                  SellCard(
                    icon: Icons.precision_manufacturing_outlined,
                    title: 'Machine Details',
                    children: [
                      for (final row in listing.machineDetailRows)
                        SpecRow(label: row.$1, value: row.$2),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (listing.specificationRows.isNotEmpty) ...[
                  SellCard(
                    icon: Icons.tune,
                    title: 'Machine Specifications',
                    children: [
                      for (final row in listing.specificationRows)
                        SpecRow(label: row.$1, value: row.$2),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (listing.commercialRows.isNotEmpty) ...[
                  SellCard(
                    icon: Icons.payments_outlined,
                    title: 'Commercial Information',
                    children: [
                      for (final row in listing.commercialRows)
                        SpecRow(label: row.$1, value: row.$2),
                      if (listing.additionalRemarks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SummaryPair(
                          label: 'Remark',
                          value: listing.additionalRemarks,
                          block: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (!listing.inspection.isEmpty) ...[
                  _InspectionCard(report: listing.inspection),
                  const SizedBox(height: 16),
                ],
                if (listing.seller.rows.any((r) => r.$2.isNotEmpty)) ...[
                  SellCard(
                    icon: Icons.person_outline,
                    title: 'Seller Information',
                    children: [
                      for (final row in listing.seller.rows)
                        if (row.$2.trim().isNotEmpty)
                          SpecRow(label: row.$1, value: row.$2),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (listing.requiredPhotos.isNotEmpty) ...[
                  SellCard(
                    icon: Icons.checklist_rtl,
                    title: 'Required Photos',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final view in listing.requiredPhotos)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.11,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    size: 13,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    view,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (listing.specs.isNotEmpty) ...[
                  SellCard(
                    icon: Icons.settings_outlined,
                    title: 'Technical Specifications',
                    children: [
                      for (final spec in listing.specs) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              Text(
                                spec.$1,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    spec.$2,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (spec != listing.specs.last)
                          const Divider(height: 1),
                      ],
                      if (listing.features.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final feature in listing.features)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.scaffold,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SellCard(
                  icon: Icons.history,
                  title: 'Listing Status',
                  children: [
                    for (var i = 0; i < listing.timeline.length; i++)
                      ListingTimelineRow(
                        event: listing.timeline[i],
                        isLast: i == listing.timeline.length - 1,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SellCard(
                  icon: Icons.folder_outlined,
                  title: 'Documents',
                  children: [
                    if (listing.documents.isEmpty)
                      const Text(
                        'No documents attached to this listing.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      )
                    else
                      for (final doc in listing.documents)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 19,
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${doc.size} • ${doc.uploadedOn}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _todo(context, doc.name),
                                icon: const Icon(
                                  Icons.download_outlined,
                                  size: 19,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => _todo(context, 'Edit listing'),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text(
                    'Edit Listing',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: () => _todo(context, 'Contact broker'),
                  icon: const Icon(Icons.support_agent_outlined, size: 18),
                  label: const Text(
                    'Contact Broker',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section 7 — filled by the MachSetu inspector, read-only for the seller.
class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.report});

  final InspectionReport report;

  static Color _tint(String rating) => switch (rating) {
    'Excellent' => AppColors.success,
    'Good' => AppColors.brandBlue,
    'Average' => AppColors.accent,
    'Poor' => AppColors.danger,
    _ => AppColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    return SellCard(
      icon: Icons.fact_check_outlined,
      title: 'Inspection Report',
      children: [
        for (final point in report.points) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.point,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (point.remark.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          point.remark,
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _tint(point.rating).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    point.rating,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _tint(point.rating),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (report.remarks.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 12),
          SummaryPair(
            label: 'Inspector Remarks',
            value: report.remarks,
            block: true,
          ),
        ],
        if (report.inspectorName.isNotEmpty) ...[
          const SizedBox(height: 14),
          SpecRow(label: 'Inspector Name', value: report.inspectorName),
          SpecRow(label: 'Inspection Date', value: report.inspectedOn),
        ],
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, this.overlay});

  final String path;
  final String? overlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 82,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.steelBright),
            ),
            if (overlay != null)
              ColoredBox(
                color: AppColors.navyDeep.withValues(alpha: 0.55),
                child: Center(
                  child: Text(
                    overlay!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeadCard extends StatelessWidget {
  const _HeadCard({required this.listing});

  final SellListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${listing.year} ${listing.title}',
            style: const TextStyle(
              fontSize: 21,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            listing.subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            listing.price,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ref: ${listing.reference}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Fact(label: 'MANUFACTURER', value: listing.brand),
              ),
              Expanded(
                child: _Fact(
                  label: 'WORKING HOURS',
                  value: listing.workingHours.isEmpty
                      ? 'Not stated'
                      : '${listing.workingHours} hrs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Fact(
                  label: 'LOCATION',
                  value: listing.location,
                  icon: Icons.place_outlined,
                ),
              ),
              Expanded(
                child: _Fact(
                  label: 'CONDITION',
                  value: listing.condition,
                  asChip: true,
                ),
              ),
            ],
          ),
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),
            const Text(
              'CONDITION NOTES',
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listing.description,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.icon,
    this.asChip = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool asChip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (asChip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          )
        else
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
