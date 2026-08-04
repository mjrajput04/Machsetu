import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../data/sell_store.dart';

/// Numbered step indicator with a connecting rail.
class StepTrail extends StatelessWidget {
  const StepTrail({
    super.key,
    required this.labels,
    required this.current,
    this.onTap,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Container(
                  height: 2,
                  color: i <= current ? AppColors.navy : AppColors.border,
                ),
              ),
            ),
          GestureDetector(
            onTap: onTap == null ? null : () => onTap!(i),
            child: SizedBox(
              width: 62,
              child: Column(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == current
                          ? AppColors.accent
                          : i < current
                          ? AppColors.navy
                          : AppColors.border.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: i < current
                        ? const Icon(Icons.check, size: 17, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: i == current
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == current
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SellCard extends StatelessWidget {
  const SellCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.onEdit,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
              Icon(icon, size: 19, color: AppColors.brandBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      color: AppColors.brandBlue,
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

class SellField extends StatelessWidget {
  const SellField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.isLast = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
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
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.navy, width: 1.4),
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

class SellDropdown extends StatelessWidget {
  const SellDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

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
          DropdownButtonFormField<String>(
            initialValue: options.contains(value) ? value : null,
            isExpanded: true,
            icon: const Icon(Icons.expand_more, size: 20),
            hint: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
            ),
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.navy, width: 1.4),
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: onChanged,
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

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.path,
    required this.onRemove,
    this.isMain = false,
  });

  final String path;
  final VoidCallback onRemove;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: AppColors.steelBright,
            ),
          ),
          if (isMain)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Main',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                height: 26,
                width: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 15,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewThumb extends StatelessWidget {
  const ReviewThumb({super.key, required this.path, required this.isMain});

  final String path;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: 116,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.steelBright,
              ),
            ),
            if (isMain)
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Main',
                    style: TextStyle(
                      fontSize: 9.5,
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

class DocTypeCard extends StatelessWidget {
  const DocTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.attached,
    required this.onUpload,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int attached;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasFiles = attached > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: hasFiles ? AppColors.scaffold : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: hasFiles
                      ? AppColors.navy
                      : AppColors.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: hasFiles ? Colors.white : AppColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (hasFiles)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$attached file${attached == 1 ? '' : 's'} attached',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: AppColors.navy,
                backgroundColor: hasFiles
                    ? AppColors.border.withValues(alpha: 0.5)
                    : AppColors.surface,
                side: BorderSide(
                  color: hasFiles ? Colors.transparent : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onUpload,
              icon: Icon(hasFiles ? Icons.add : Icons.upload, size: 17),
              label: Text(
                hasFiles ? 'Add More' : 'Upload',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentRow extends StatelessWidget {
  const DocumentRow({super.key, required this.document, this.onRemove});

  final SellDocument document;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
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
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${document.size} • ${document.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryPair extends StatelessWidget {
  const SummaryPair({
    super.key,
    required this.label,
    required this.value,
    this.asChip = false,
    this.block = false,
  });

  final String label;
  final String value;
  final bool asChip;
  final bool block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          Text(
            value,
            style: TextStyle(
              fontSize: block ? 13.5 : 15,
              height: block ? 1.6 : 1.3,
              fontWeight: block ? FontWeight.w400 : FontWeight.w700,
              color: block ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

/// Dashed rounded rectangle used by the photo drop zone.
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.steel.withValues(alpha: 0.55);

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(12),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 7).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
