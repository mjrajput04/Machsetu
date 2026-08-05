import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The MachSetu mark. Renders [assetPath] — the MS monogram — and falls back
/// to a machine glyph only if the file is missing.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 72,
    this.background = Colors.transparent,
    this.fallbackColor = AppColors.navy,
  });

  static const String assetPath = 'assets/images/machsetu_logo.png';

  final double size;

  /// Optional plate behind the mark. The artwork already has its own depth,
  /// so this stays transparent by default.
  final Color background;

  /// Colour of the placeholder glyph if the asset ever fails to load.
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.precision_manufacturing,
          size: size * 0.55,
          color: fallbackColor,
        ),
      ),
    );
  }
}

/// The MACHSETU wordmark artwork. The file already carries the strapline, so
/// nothing else needs to sit under it. Falls back to the drawn wordmark and
/// tagline if the asset is ever missing.
class BrandTextLogo extends StatelessWidget {
  const BrandTextLogo({
    super.key,
    this.width = 240,
    this.assetPath = authAsset,
  });

  /// Full lockup with the chevron — used on the auth screens.
  static const String authAsset = 'assets/images/machsetu_text.png';

  /// Flatter crop that suits the short app-bar title slot.
  static const String appBarAsset = 'assets/images/machsetu_text2.png';

  final double width;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandWordmark(fontSize: width * 0.11),
          const SizedBox(height: 8),
          const BrandTagline(),
        ],
      ),
    );
  }
}

/// "MACHSETU" wordmark in the logo's two-tone treatment: brushed steel for
/// MACH, royal blue for SETU.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.fontSize = 26,
    this.letterSpacing = 0.5,
    this.machColor = AppColors.gunmetal,
    this.setuColor = AppColors.accent,
    this.metallic = false,
  });

  /// Renders MACH with a brushed-metal gradient — intended for dark
  /// backgrounds such as the splash screen.
  const BrandWordmark.metallic({
    super.key,
    this.fontSize = 34,
    this.letterSpacing = 1.2,
    this.setuColor = AppColors.accentGlow,
  })  : machColor = AppColors.steelBright,
        metallic = true;

  final double fontSize;
  final double letterSpacing;
  final Color machColor;
  final Color setuColor;
  final bool metallic;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      // Slanted, like the lettering in the logo artwork.
      fontStyle: FontStyle.italic,
      letterSpacing: letterSpacing,
      height: 1.05,
    );

    final mach = Text('MACH', style: style.copyWith(color: machColor));

    return FittedBox(
      // Shrinks rather than overflowing in tight app-bar title slots.
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (metallic)
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  AppColors.steelGradient.createShader(bounds),
              child: mach,
            )
          else
            mach,
          Text('SETU', style: style.copyWith(color: setuColor)),
        ],
      ),
    );
  }
}

/// "— FASTER DEALS. STRONGER INDUSTRY. —" strapline from the logo lockup.
class BrandTagline extends StatelessWidget {
  const BrandTagline({
    super.key,
    this.color = AppColors.steel,
    this.fontSize = 10.5,
    this.letterSpacing = 1.6,
    this.showRules = true,
  });

  static const String text = 'FASTER DEALS.  STRONGER INDUSTRY.';

  final Color color;
  final double fontSize;
  final double letterSpacing;
  final bool showRules;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );

    final line = showRules
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _rule(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: label,
              ),
              _rule(),
            ],
          )
        : label;

    // Shrinks rather than overflowing on narrow handsets.
    return FittedBox(fit: BoxFit.scaleDown, child: line);
  }

  Widget _rule() => Container(
        height: 1.4,
        width: 16,
        color: color.withValues(alpha: 0.6),
      );
}
