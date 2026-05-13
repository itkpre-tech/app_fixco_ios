import 'package:flutter/material.dart';
import '../cards/project_card.dart';
import '../models/project_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_ui_kit.dart';
import 'home_empty_state.dart';
import 'home_error_state.dart';

class HomeProjectsCarousel extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<ProjectModel> projects;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onRetry;
  final void Function(String projectId) onViewProject;

  const HomeProjectsCarousel({
    super.key,
    required this.isLoading,
    required this.error,
    required this.projects,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRetry,
    required this.onViewProject,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5)),
      );
    }
    if (error != null) {
      return HomeErrorState(
        icon: Icons.image_not_supported_rounded,
        message: 'Failed to load projects',
        onRetry: onRetry,
      );
    }
    if (projects.isEmpty) {
      return const HomeEmptyState(
        icon: Icons.folder_off_rounded,
        title: 'No Projects Yet',
        subtitle: 'Completed projects will appear here.',
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => onPageChanged(p % projects.length),
            itemBuilder: (_, i) {
              final project = projects[i % projects.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: HomeProjectCard(
                  project: project,
                  onView: () => onViewProject(project.id),
                ),
              );
            },
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
              SmoothDots(count: projects.length, current: currentPage),
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
        const SizedBox(height: 6),
      ],
    );
  }
}