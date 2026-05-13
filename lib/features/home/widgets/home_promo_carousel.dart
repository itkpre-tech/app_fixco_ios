import 'package:flutter/material.dart';
import '../cards/promo_card.dart';
import '../models/promo_data.dart';
import '../shared/home_ui_kit.dart';

class HomePromoCarousel extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const HomePromoCarousel({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 164,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % kPromos.length),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PromoCard(promo: kPromos[i % kPromos.length]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CarouselArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => controller.previousPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                ),
              ),
              SmoothDots(count: kPromos.length, current: currentPage),
              CarouselArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => controller.nextPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}