import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class _HeroSlide {
  const _HeroSlide({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  final String badge;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
}

/// Full-width e-commerce hero carousel (edge-to-edge).
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key, this.onShopTap});

  final VoidCallback? onShopTap;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const _slides = [
    _HeroSlide(
      badge: 'ສິນຄ້າໃໝ່',
      title: 'ສວຍສຸຂະພາບ\nທຸກວັນ',
      subtitle: 'ຊື້ສິນຄ້າຄຸນນະພາບ ຈາກຈີນ',
      gradient: AppColors.heroGradient,
      icon: Icons.spa_rounded,
    ),
    _HeroSlide(
      badge: 'ສົ່ງຟຣີ',
      title: 'ຈັດສົ່ງ\nທົ່ວລາວ',
      subtitle: 'ສັ່ງຜ່ານແອັບ · ຊຳລະເມື່ອຮັບສິນຄ້າ',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF043D2E), Color(0xFF064E3B), Color(0xFF047857)],
      ),
      icon: Icons.local_shipping_rounded,
    ),
    _HeroSlide(
      badge: 'ໂປຣໂມຊັ່ນ',
      title: 'ອາຫານເສີມ\nແລະ ຜິວຫນັງ',
      subtitle: 'ເລືອກຫມວດສິນຄ້າ ແລະ ຊື້ເລີຍ',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF022C22), Color(0xFF064E3B), Color(0xFF065F46)],
      ),
      icon: Icons.favorite_rounded,
    ),
  ];

  final _pageCtrl = PageController();
  Timer? _autoTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  double _heroHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w * 0.44).clamp(168.0, 210.0);
  }

  @override
  Widget build(BuildContext context) {
    final height = _heroHeight(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => _HeroSlideView(
              slide: _slides[index],
              onShopTap: widget.onShopTap,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroSlideView extends StatelessWidget {
  const _HeroSlideView({required this.slide, this.onShopTap});

  final _HeroSlide slide;
  final VoidCallback? onShopTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onShopTap,
        child: Ink(
          decoration: BoxDecoration(gradient: slide.gradient),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -24,
                top: -16,
                child: Icon(
                  slide.icon,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slide.badge,
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      slide.title,
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      slide.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: onShopTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'ຊື້ເລີຍ',
                        style: GoogleFonts.notoSansLao(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
