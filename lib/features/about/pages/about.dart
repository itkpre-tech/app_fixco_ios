import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  TextStyle get _title => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset("assets/images/fixco.png", height: 110),
              ),
            ),

            const SizedBox(height: 25),
            Text("About Us", style: _title),
            const SizedBox(height: 10),

            _glass(
              child: const Text(
                "MEDCO Contracting delivers reliable, high-quality maintenance and contracting services across the UAE. Expert-driven solutions with fast response and proven client satisfaction.",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: StatCard("30+", "Years")),
                SizedBox(width: 10),
                Expanded(child: StatCard("22", "Nationalities")),
                SizedBox(width: 10),
                Expanded(child: StatCard("25", "Languages")),
              ],
            ),

            const SizedBox(height: 20),
            const InfoCard(
              icon: Icons.flag,
              title: "Mission",
              desc: "Deliver high-quality services with trust.",
            ),
            const SizedBox(height: 12),
            const InfoCard(
              icon: Icons.visibility,
              title: "Vision",
              desc: "To become a leading service provider.",
            ),

            const SizedBox(height: 25),
            Text("Our Branches", style: _title),
            const SizedBox(height: 10),

            BranchCard(
              icon: Icons.location_city_outlined,
              branches: const [
                BranchItem(
                  name: "Dubai",
                  subtitle: "Head Office",
                  url: "https://kingspalace.com/",
                  isHeadOffice: true,
                ),
                BranchItem(name: "Sharjah", url: "https://kingspalace.com/"),
                BranchItem(name: "Ajman", url: "https://kingspalace.com/"),
              ],
            ),

            const SizedBox(height: 12),

            Text("International Branches", style: _title),
            const SizedBox(height: 10),

            BranchCard(
              icon: Icons.public_outlined,
              branches: const [
                BranchItem(name: "Romania", url: "https://kingspalace.com/"),
              ],
            ),

            const SizedBox(height: 12),

            Text("Sister Companies", style: _title),
            const SizedBox(height: 10),

            BranchCard(
              icon: Icons.business_outlined,
              branches: const [
                BranchItem(
                  name: "Kings' Palace Real Estate",
                  url: "https://kingspalace.com/",
                ),
                BranchItem(
                  name: "Kings' Land Consultancy",
                  url: "https://kingspalace.com/",
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text("Certifications", style: _title),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
              children: const [
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "ISO Environmental",
                ),
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "Health & Safety",
                ),
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "Quality Management",
                ),
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "Dubai Chamber",
                ),
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "ISO 9001",
                ),
                CertCard(
                  imagePath: "assets/images/certificate.jpg",
                  title: "ISO 14001",
                ),
              ],
            ),

            const SizedBox(height: 25),
            Text("What Our Clients Say", style: _title),
            const SizedBox(height: 14),

            const ReviewCarousel(
              reviews: [
                ReviewData(
                  quote:
                  "Great environment, professional and nice people. They care about their clients and train their agents frequently.",
                  name: "Mohamed Al Hamdhy",
                  role: "Property Investor",
                  imagePath: "assets/images/client1.jpg",
                ),
                ReviewData(
                  quote:
                  "The best real estate company I have ever dealt with. Very professional, experienced and helpful agents.",
                  name: "Lisa Cudrow",
                  role: "Homeowner",
                  imagePath: "assets/images/client2.jpg",
                ),
                ReviewData(
                  quote:
                  "We had a great experience with Kings Palace Real Estate. They went above and beyond to help us move.",
                  name: "John Smith",
                  role: "Business Owner",
                  imagePath: "assets/images/client3.jpg",
                ),
              ],
            ),

            const SizedBox(height: 25),
            Text("Leadership", style: _title),
            const SizedBox(height: 10),

            _glass(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "assets/images/leader.jpg",
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.white12,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "H.E. Dr. Sami Al Sawalehi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Founder & Visionary Leader",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Leading KPRE's growth across the UAE and international markets since 1991.",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const FooterWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CertCard extends StatelessWidget {
  final String imagePath;
  final String title;

  const CertCard({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white.withValues(alpha: 0.06),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewData {
  final String quote;
  final String name;
  final String role;
  final String imagePath;

  const ReviewData({
    required this.quote,
    required this.name,
    required this.role,
    required this.imagePath,
  });
}

class ReviewCarousel extends StatefulWidget {
  final List<ReviewData> reviews;

  const ReviewCarousel({super.key, required this.reviews});

  @override
  State<ReviewCarousel> createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<ReviewCarousel> {
  final PageController _pageCtrl = PageController(viewportFraction: 0.88);
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.reviews.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ReviewCard(data: widget.reviews[index]),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.reviews.length, (i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewData data;

  const ReviewCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ClipOval(
                  child: Image.asset(
                    data.imagePath,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white12,
                      child: const Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u201C',
                style: TextStyle(
                  fontSize: 34,
                  height: 0.85,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.quote,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "FixCo Services",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Version 1.0.0",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
        ),

        const SizedBox(height: 6),

        Text(
          "© 2026 All Rights Reserved",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30), fontSize: 11),
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}

class BranchItem {
  final String name;
  final String? subtitle;
  final String url;
  final bool isHeadOffice;

  const BranchItem({
    required this.name,
    required this.url,
    this.subtitle,
    this.isHeadOffice = false,
  });
}

class BranchCard extends StatelessWidget {
  final IconData icon;
  final List<BranchItem> branches;

  const BranchCard({super.key, required this.icon, required this.branches});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(branches.length, (index) {
          final b = branches[index];
          final isLast = index == branches.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _launch(b.url),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 18, color: Colors.white70),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    b.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (b.isHeadOffice) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                      BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.amber
                                            .withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'HQ',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.amber,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (b.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                b.subtitle!,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),

              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.07),
                  indent: 66,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style:
                  const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}