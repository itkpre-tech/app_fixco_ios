import 'package:flutter/material.dart';
import '../cards/service_card.dart';
import '../models/service_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_ui_kit.dart';
import 'home_empty_state.dart';
import 'home_error_state.dart';

class HomeServicesGrid extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<ServiceModel> services;
  final String committedQuery;
  final VoidCallback onRetry;
  final VoidCallback onClearSearch;

  const HomeServicesGrid({
    super.key,
    required this.isLoading,
    required this.error,
    required this.services,
    required this.committedQuery,
    required this.onRetry,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5)),
        ),
      );
    }

    if (error != null) {
      return SliverToBoxAdapter(
        child: HomeErrorState(
          icon: Icons.wifi_off_rounded,
          message: 'Failed to load services',
          onRetry: onRetry,
        ),
      );
    }

    if (services.isEmpty) {
      return SliverToBoxAdapter(
        child: HomeEmptyState(
          icon: Icons.construction_rounded,
          title: 'No Services Found',
          subtitle: committedQuery.isNotEmpty
              ? 'Nothing matched "$committedQuery"'
              : 'Services will appear here soon.',
          action: committedQuery.isNotEmpty
              ? PillButton(
            label: 'Show all',
            textColor: kPrimary,
            borderColor: kPrimary.withValues(alpha: 0.4),
            onTap: onClearSearch,
          )
              : null,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
              (_, i) => ServiceCard(service: services[i]),
          childCount: services.length,
        ),
      ),
    );
  }
}