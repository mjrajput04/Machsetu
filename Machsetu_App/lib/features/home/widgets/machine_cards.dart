import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/machines.dart';

/// Listing photo. Renders the bundled asset when the listing has one and
/// falls back to a brushed-steel panel with the machine icon otherwise — so a
/// missing or not-yet-uploaded image never breaks the card layout.
class MachinePhoto extends StatelessWidget {
  const MachinePhoto({
    super.key,
    required this.icon,
    this.image,
    this.height = 170,
  });

  final IconData icon;
  final String? image;
  final double height;

  @override
  Widget build(BuildContext context) {
    final path = image;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: path == null
          ? _fallback()
          : Image.asset(
              path,
              height: height,
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
          size: height * 0.36,
          color: AppColors.navy.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class FeaturedMachineCard extends StatelessWidget {
  const FeaturedMachineCard({super.key, required this.machine, this.onTap});

  final Machine machine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
              MachinePhoto(icon: machine.icon, image: machine.image),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    machine.badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.navy,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machine.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            machine.subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 74,
                      child: Text(
                        machine.note,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: AppColors.border),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      for (var i = 0; i < machine.specs.length; i++) ...[
                        if (i > 0)
                          Container(
                            height: 34,
                            width: 1,
                            color: AppColors.border,
                          ),
                        Expanded(child: _SpecTile(spec: machine.specs[i])),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    onPressed: onTap,
                    child: Text(machine.ctaLabel),
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

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.spec});

  final MachineSpec spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(spec.icon, size: 16, color: AppColors.brandBlue),
        const SizedBox(height: 6),
        Text(
          spec.label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          spec.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}

class CompactMachineCard extends StatefulWidget {
  const CompactMachineCard({super.key, required this.machine, this.onTap});

  final Machine machine;
  final VoidCallback? onTap;

  @override
  State<CompactMachineCard> createState() => _CompactMachineCardState();
}

class _CompactMachineCardState extends State<CompactMachineCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
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
                MachinePhoto(
                  icon: widget.machine.icon,
                  image: widget.machine.image,
                  height: 104,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _saved = !_saved),
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _saved ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: _saved ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.machine.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.machine.year,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
