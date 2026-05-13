import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fixco/services/api.dart';
import '../../home/shared/home_constants.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  final LatLng _location = const LatLng(25.277789, 55.346793);

  // Dummy refresh for the RefreshIndicator
  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kPrimary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final result = await Api.sendContact(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _messageController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (result['status'] == 'success') {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Failed to send message. Please try again.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _infoCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _socialItem({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 32, child: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 30; // extra margin

    return Scaffold(
      backgroundColor: Colors.white,
      // Ensure the keyboard doesn't overlap the bottom button
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(child: ContactTitleBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Address
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _infoCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Medco Contracting L.L.C",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Al Andalus Building, Abu Hail Road,\nDeira, Dubai, UAE\nPO Box 10839",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Working hours
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _infoCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Working Hours",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sunday - Thursday: 08:30 AM - 08:00 PM",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        "Friday: 08:30 AM - 07:00 PM",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        "Saturday: Closed",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Social Media
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _infoCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Social Media",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _socialItem(
                        icon: Image.network(
                          "https://img.icons8.com/color/48/phone",
                          width: 24,
                        ),
                        title: "Call",
                        subtitle: "800 5773",
                        onTap: () => _launch("tel:8005773"),
                      ),
                      _socialItem(
                        icon: Image.network(
                          "https://img.icons8.com/color/48/whatsapp--v1.png",
                          width: 24,
                        ),
                        title: "WhatsApp",
                        subtitle: "+971 50 345 5855",
                        onTap: () => _launch("https://wa.me/971503455855"),
                      ),
                      _socialItem(
                        icon: Image.network(
                          "https://img.icons8.com/color/48/email--v1.png",
                          width: 24,
                        ),
                        title: "Email",
                        subtitle: "info@medco-maintanance.com",
                        onTap: () => _launch("mailto:info@medco-maintanance.com"),
                      ),
                      _socialItem(
                        icon: Image.network(
                          "https://img.icons8.com/color/48/instagram-new--v1.png",
                          width: 24,
                        ),
                        title: "Instagram",
                        subtitle: "@medcocontracting",
                        onTap: () => _launch(
                          "https://www.instagram.com/medcocontracting/",
                        ),
                      ),
                      _socialItem(
                        icon: Image.network(
                          "https://img.icons8.com/color/48/facebook-new.png",
                          width: 24,
                        ),
                        title: "Facebook",
                        subtitle: "@medcocontracting",
                        onTap: () =>
                            _launch("https://facebook.com/medcocontracting"),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // Map
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find us on map",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _location,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("office"),
                              position: _location,
                            ),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // Contact Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Contact Form",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoCard(
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _input("Your Name"),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Please enter your name"
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _input("Email Address"),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Email required"
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _input("Mobile Number"),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _input("Your Message"),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Please enter your message"
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSending ? null : _sendMessage,
                                child: _isSending
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  "Send Message",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),

            // IMPORTANT: Extra bottom padding to avoid button being hidden by bottom nav bar or home indicator
            SliverPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              sliver: SliverToBoxAdapter(child: const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Title bar (identical to ProfileTitleBar)
// ---------------------------------------------------------------------
class ContactTitleBar extends StatelessWidget {
  const ContactTitleBar({super.key});

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
                          width: 5,
                          height: 5,
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

                  // Title
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                      height: 1.1,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'We’d love to hear from you',
                    style: TextStyle(color: kTextLight, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}