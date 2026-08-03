import 'package:flutter/material.dart';

/// Palette sampled from the MachSetu logo — royal blue, brushed steel and
/// gunmetal, with an industrial orange highlight.
class AppColors {
  AppColors._();

  // Brand blues
  static const Color navy = Color(0xFF0E2E5C);
  static const Color navyDark = Color(0xFF0A2244);
  static const Color navyDeep = Color(0xFF061627);

  /// Medium brand blue used for card titles, spec values, section headings,
  /// primary buttons and links. Lighter than [navy], which is reserved for
  /// dark surfaces (promo banner, active category chip).
  static const Color brandBlue = Color(0xFF1A5490);

  /// Industrial orange — CTAs, the FAB, the active tab and section links.
  static const Color accent = Color(0xFFF97316);
  static const Color accentDark = Color(0xFFC2410C);
  static const Color accentGlow = Color(0xFFFB923C);

  // Brushed steel
  static const Color steel = Color(0xFF8E99A4);
  static const Color steelLight = Color(0xFFC9D2DB);
  static const Color steelBright = Color(0xFFEEF2F6);
  static const Color gunmetal = Color(0xFF2A3038);

  // Surfaces
  static const Color scaffold = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color fieldFill = Color(0xFFFBFCFE);

  // Text
  static const Color textPrimary = Color(0xFF0E2338);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Lines / states
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C2843), Color(0xFF0A1F3A), Color(0xFF050E1B)],
  );

  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12417D), Color(0xFF0A2244)],
  );

  static const LinearGradient machineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8E1EC), Color(0xFFAEBDCE)],
  );

  /// Brushed-metal sweep used for the "MACH" half of the wordmark.
  static const LinearGradient steelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4F7FA),
      Color(0xFFB6C0CB),
      Color(0xFFEDF1F5),
      Color(0xFF98A4B0),
    ],
    stops: [0.0, 0.35, 0.6, 1.0],
  );
}
