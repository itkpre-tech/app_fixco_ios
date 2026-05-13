import 'package:flutter/material.dart';
import '../cards/offer_card.dart';
import '../models/offer_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_ui_kit.dart';
import 'home_error_state.dart';

class HomeOffersSection extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<OfferModel> offers;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onRetry;

  const HomeOffersSection({
    super.key,
    required this.isLoading,
    required this.error,
    required this.offers,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 190,
        child: Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5)),
      );
    }
    if (error != null) {
      return HomeErrorState(
        icon: Icons.local_offer_outlined,
        message: 'Failed to load offers',
        onRetry: onRetry,
      );
    }
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % offers.length),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: OfferCard(offer: offers[i % offers.length]),
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
              SmoothDots(count: offers.length, current: currentPage),
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