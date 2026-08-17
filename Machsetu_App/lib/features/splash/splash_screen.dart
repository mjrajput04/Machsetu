import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_logo.dart';
import 'widgets/splash_painters.dart';

/// Animated brand intro.
///
/// One 3.2s timeline drives the whole sequence — badge draws itself, logo
/// springs in, the wordmark types out letter by letter, then the loader fills.
/// Two looping controllers add ambient motion so nothing sits still.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _wordmark = 'MACHSETU';

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  /// Slow ambient clock — aurora drift, grid drift, ring rotation.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  /// Breathing clock for the halo and loader dot.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  /// Fades and lifts the whole screen away on exit.
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late final Animation<double> _backdrop = _curve(0.00, 0.30);
  late final Animation<double> _markDraw = _curve(0.05, 0.50, Curves.easeInOut);
  late final Animation<double> _logoFade = _curve(0.18, 0.44);
  late final Animation<double> _logoScale = Tween<double>(begin: 0.55, end: 1)
      .animate(
        CurvedAnimation(
          parent: _intro,
          curve: const Interval(0.18, 0.56, curve: Curves.easeOutBack),
        ),
      );
  late final Animation<double> _tagline = _curve(0.66, 0.82);
  late final Animation<double> _rule = _curve(0.70, 0.88, Curves.easeOutCubic);
  late final Animation<double> _loader = _curve(0.60, 1.00, Curves.easeInOut);
  late final Animation<double> _hud = _curve(0.78, 1.00);

  Animation<double> _curve(
    double begin,
    double end, [
    Curve curve = Curves.easeOut,
  ]) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    );
  }

  /// Each letter gets its own slice of the 0.46–0.72 window.
  Animation<double> _letter(int index) {
    const start = 0.46;
    const span = 0.26;
    final slot = span / _wordmark.length;
    final begin = start + slot * index;
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(
        begin,
        (begin + slot * 2.6).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _run();
  }

  Future<void> _run() async {
    await _intro.forward();
    if (!mounted) return;

    // Returning users skip straight to the marketplace.
    final loggedIn = await SessionStore.instance.isLoggedIn();
    if (!mounted) return;

    // Deliberately not awaited: the content lifts away while the next route
    // fades in over the same gradient, so the two motions overlap instead of
    // leaving a gap between them.
    _exit.forward();
    Navigator.of(
      context,
    ).pushReplacementNamed(loggedIn ? AppRoutes.home : AppRoutes.login);
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _pulse.dispose();
    _exit.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The gradient deliberately sits OUTSIDE the exit animation. The next
      // route fades in on top of this screen, so if the whole thing faded out
      // there would be a blank flash underneath during the hand-off.
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            _backdropLayers(),
            AnimatedBuilder(
              animation: _exit,
              builder: (context, child) {
                return Opacity(
                  opacity: 1 - _exit.value,
                  child: Transform.scale(
                    scale: 1 + _exit.value * 0.06,
                    child: child,
                  ),
                );
              },
              child: SafeArea(
                child: Stack(
                  children: [
                    _topHud(),
                    Center(child: _centrepiece()),
                    _bottomHud(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------- backdrop

  Widget _backdropLayers() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_ambient, _intro]),
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: _backdrop.value,
                  child: CustomPaint(painter: AuroraPainter(_ambient.value)),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: DriftGridPainter(
                    _ambient.value * 6,
                    opacity: _backdrop.value,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------ centrepiece

  Widget _centrepiece() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          width: 250,
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _ambient, _pulse]),
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(232, 232),
                    painter: MarkPainter(
                      draw: _markDraw.value,
                      spin: _ambient.value,
                      pulse: _pulse.value,
                    ),
                  ),
                  // Three dots orbiting the badge.
                  for (var i = 0; i < 3; i++)
                    Transform.rotate(
                      angle:
                          _ambient.value * 2 * math.pi + i * (2 * math.pi / 3),
                      child: Transform.translate(
                        offset: const Offset(0, -122),
                        child: Opacity(
                          opacity: _markDraw.value,
                          child: Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.7,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const BrandLogo(
                        size: 132,
                        fallbackColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        _animatedWordmark(),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _tagline,
          child: const BrandTagline(
            color: AppColors.steelLight,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _rule,
          builder: (context, _) => Container(
            height: 1.5,
            width: 120 * _rule.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0),
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _hud,
          child: Text(
            "INDIA'S PREMIER B2B INDUSTRIAL NEXUS",
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.7,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
        const SizedBox(height: 46),
        _loaderBar(),
      ],
    );
  }

  /// MACHSETU, one letter at a time, under a brushed-metal sweep.
  Widget _animatedWordmark() {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.steelGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _wordmark.length; i++)
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) {
                final t = _letter(i).value;
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 22),
                    child: Transform.scale(
                      scale: 0.82 + t * 0.18,
                      child: Text(
                        _wordmark[i],
                        style: const TextStyle(
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Determinate bar plus a counter, so the wait reads as progress.
  Widget _loaderBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _pulse]),
      builder: (context, _) {
        final value = _loader.value;
        return Opacity(
          opacity: _loader.status == AnimationStatus.dismissed ? 0 : 1,
          child: Column(
            children: [
              SizedBox(
                width: 190,
                child: Stack(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [AppColors.accentGlow, AppColors.accent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(
                        alpha: 0.35 + _pulse.value * 0.65,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SYNCING GLOBAL NODES',
                    style: TextStyle(
                      fontSize: 11.5,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------- hud

  Widget _topHud() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 20, 0),
        child: FadeTransition(
          opacity: _hud,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _mono('INDUSTRIAL_NEXUS_SYNC', opacity: 0.42),
              const SizedBox(height: 6),
              _mono(_stamp, opacity: 0.26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomHud() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: FadeTransition(
          opacity: _hud,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Row(
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(
                          alpha: 0.4 + _pulse.value * 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    child!,
                  ],
                ),
                child: _mono('KERNEL: V4.2.0_STABLE', opacity: 0.5),
              ),
              const SizedBox(height: 8),
              _mono('LOCATION: IN_GIGA_HUB', opacity: 0.3),
              const SizedBox(height: 8),
              _mono('PROTOCOL: SECURE_V3_AES', opacity: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  String get _stamp {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}  '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  Widget _mono(String text, {double opacity = 0.4}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
