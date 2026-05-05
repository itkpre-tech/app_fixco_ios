import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fixco/services/api.dart';

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

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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

  Widget _glassButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isSending ? null : _sendMessage,
      child: _glass(
        child: Center(
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
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Get in touch",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              _glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Medco Contracting L.L.C",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Al Andalus Building, Abu Hail Road,\nDeira, Dubai, UAE\nPO Box 10839",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Working Hours",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Sunday - Thursday: 08:30 AM - 08:00 PM",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      "Friday: 08:30 AM - 07:00 PM",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      "Saturday: Closed",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Social Media",
                      style: TextStyle(
                        color: Colors.white,
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
              const SizedBox(height: 25),

              const Text(
                "Find us on map",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              const SizedBox(height: 25),

              const Text(
                "Contact Form",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _glass(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Your Name"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Please enter your name"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Email Address"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Email required"
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Mobile Number"),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: _input("Your Message"),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Please enter your message"
                            : null,
                      ),
                      const SizedBox(height: 15),
                      _glassButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}