import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _fade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.86,
    end: 1.0,
  ).animate(
    CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
  );

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _intro.forward();
    _navTimer = Timer(const Duration(milliseconds: 3000), _goNext);
  }

  /// Returning users skip straight to the marketplace; everyone else lands on
  /// login. The session read is fast, but it is awaited after the splash
  /// animation so the branding is never cut short.
  Future<void> _goNext() async {
    final loggedIn = await SessionStore.instance.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _intro.dispose();
    _pulse.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  String get _stamp {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}  '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              _GridOverlay(),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 20, 0),
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
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: SizedBox(
                          height: 260,
                          width: 300,
                          child: CustomPaint(
                            painter: _HexPainter(),
                            child: const Center(
                              child: BrandLogo(
                                size: 150,
                                fallbackColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          const BrandWordmark.metallic(),
                          const SizedBox(height: 14),
                          const BrandTagline(
                            color: AppColors.steelLight,
                            fontSize: 11.5,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            width: 90,
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "INDIA'S PREMIER B2B INDUSTRIAL NEXUS",
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 54),
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, child) {
                              return Container(
                                height: 62,
                                width: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.45 + (_pulse.value * 0.55),
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.wifi_tethering,
                                  color: AppColors.accent.withValues(
                                    alpha: 0.6 + (_pulse.value * 0.4),
                                  ),
                                  size: 24,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'SYNCING GLOBAL NODES...',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _mono('SYS_AUTH_LOG: NET_NODE_CONNECT_22',
                              opacity: 0.35),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 22),
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _mono('KERNEL: V4.2.0_STABLE', opacity: 0.5),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _mono('LOCATION: IN_GIGA_HUB', opacity: 0.3),
                        const SizedBox(height: 8),
                        _mono('PROTOCOL: SECURE_V3_AES', opacity: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mono(String text, {double opacity = 0.4}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

/// Faint hexagon + circular halo behind the logo mark.
class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, halo);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);

    final radius = size.height / 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, stroke);

    canvas.drawCircle(
      center,
      radius * 0.56,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle technical grid wash over the whole background.
class _GridOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const step = 42.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
