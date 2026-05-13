import 'package:flutter/material.dart';
import 'package:fixco/features/profile/pages/profile_page.dart';
import '../shared/home_constants.dart';

class HomeTitleBar extends StatelessWidget {
  final String greeting;
  final Animation<double> pulseAnim;

  const HomeTitleBar({
    super.key,
    required this.greeting,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPrimary.withValues(alpha: 0.22), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5, height: 5,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimary),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'MEDCO CONTRACTING',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),

                  // Greeting
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      greeting,
                      key: ValueKey(greeting),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'How can we assist you today?',
                    style: TextStyle(color: kTextLight, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Profile avatar with pulse animation
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, child) => Transform.scale(scale: pulseAnim.value, child: child),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()), // ← use ProfilePage
                ),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kPrimary, kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}