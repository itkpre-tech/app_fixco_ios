import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_image_helper.dart';

class HomeProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onView;

  const HomeProjectCard({super.key, required this.project, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            HomeCachedImage(
              src: project.coverImage,
              fallback: Container(
                color: kSurfaceHigh,
                child: const Icon(Icons.image_rounded, color: kTextLight, size: 50),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.82)],
                  stops: const [0.28, 1.0],
                ),
              ),
            ),

            // Left accent bar
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPrimary, kAccent],
                  ),
                ),
              ),
            ),

            // Title + View button
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 14, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onView,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: kPrimary.withValues(alpha: 0.40), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}