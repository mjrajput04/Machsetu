import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Hero photo carousel that advances on its own.
///
/// Auto-play pauses while the buyer is dragging and resumes a few seconds
/// after they let go, so it never fights a manual swipe.
class ProductHero extends StatefulWidget {
  const ProductHero({
    super.key,
    required this.images,
    required this.icon,
    required this.onBack,
    required this.onShare,
    required this.onSave,
  });

  final List<String> images;
  final IconData icon;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onSave;

  static const Duration interval = Duration(seconds: 4);

  @override
  State<ProductHero> createState() => _ProductHeroState();
}

class _ProductHeroState extends State<ProductHero> {
  static const double _height = 330;

  final _controller = PageController();
  Timer? _timer;
  Timer? _resume;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resume?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.images.length < 2) return;

    _timer = Timer.periodic(ProductHero.interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.images.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
    _resume?.cancel();
    _resume = Timer(const Duration(seconds: 6), _startAutoPlay);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) _pauseAutoPlay();
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) => Image.asset(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(),
                ),
              ),
            ),
          ),
          // Keeps the back/share controls readable over bright photos.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.navyDeep.withValues(alpha: 0.72),
                      AppColors.navyDeep.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.navyDeep.withValues(alpha: 0.55),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: const Text(
                      'INDUSTRIAL MACHINE DETAILS  |  UNIT MODE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.5,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: AppColors.accentGlow,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: Row(
                      children: [
                        _CircleButton(
                          icon: Icons.arrow_back,
                          onTap: widget.onBack,
                        ),
                        const Spacer(),
                        _CircleButton(
                          icon: Icons.share_outlined,
                          onTap: widget.onShare,
                        ),
                        const SizedBox(width: 10),
                        _CircleButton(
                          icon: Icons.favorite_border,
                          onTap: widget.onSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: i == _index ? 20 : 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.machineGradient),
      child: Center(
        child: Icon(
          widget.icon,
          size: 90,
          color: AppColors.navy.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          width: 38,
          child: Icon(icon, size: 19, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
