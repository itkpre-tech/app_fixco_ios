    import 'dart:ui';
    import 'dart:io' show Platform;
    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
    import 'package:url_launcher/url_launcher.dart';
    import 'package:google_maps_flutter/google_maps_flutter.dart';
    import 'package:fixco/services/api.dart';
    import '../../gradient_scaffold.dart';

    // ============================================================================
    // DEEP-LINK LAUNCHER
    // Fixed rules:
    //   • tel:   → use launchUrl with platformDefault (opens dialler on both platforms)
    //   • wa.me  → try whatsapp:// scheme first (opens WhatsApp directly), fallback https
    //   • mailto → use EmailLauncher.launch() pattern with launchMode externalApp
    //   • instagram / facebook → try native app URI first, fallback to https
    //   • Never call canLaunchUrl for https links – it always returns false on Android 11+
    //     unless the scheme is declared in queries in AndroidManifest.xml
    // ============================================================================
    Future<void> _launch(String url) async {
      Uri uri = Uri.parse(url);

      // ── WhatsApp: prefer native scheme ──────────────────────────────────────
      if (url.contains('wa.me') || url.startsWith('whatsapp:')) {
        final number = url.replaceAll(RegExp(r'[^0-9]'), '');
        final nativeUri = Uri.parse('whatsapp://send?phone=$number');
        if (await canLaunchUrl(nativeUri)) {
          await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
          return;
        }
        // Fallback to wa.me web
        uri = Uri.parse('https://wa.me/$number');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // ── Phone dial ──────────────────────────────────────────────────────────
      if (url.startsWith('tel:')) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        return;
      }

      // ── Email ───────────────────────────────────────────────────────────────
      if (url.startsWith('mailto:')) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // ── Instagram: prefer native app ────────────────────────────────────────
      if (url.contains('instagram.com')) {
        final username = Uri.parse(url).pathSegments
            .where((s) => s.isNotEmpty)
            .firstOrNull ?? '';
        if (Platform.isAndroid) {
          final nativeUri = Uri.parse('intent://instagram.com/$username#Intent;scheme=https;package=com.instagram.android;end');
          if (await canLaunchUrl(nativeUri)) {
            await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
            return;
          }
        } else if (Platform.isIOS) {
          final nativeUri = Uri.parse('instagram://user?username=$username');
          if (await canLaunchUrl(nativeUri)) {
            await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
        // Fallback to browser
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return;
      }

      // ── Facebook: prefer native app ─────────────────────────────────────────
      if (url.contains('facebook.com')) {
        final slug = Uri.parse(url).pathSegments
            .where((s) => s.isNotEmpty)
            .firstOrNull ?? '';
        if (Platform.isAndroid) {
          final nativeUri = Uri.parse('fb://facewebmodal/f?href=$url');
          if (await canLaunchUrl(nativeUri)) {
            await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
            return;
          }
        } else if (Platform.isIOS) {
          final nativeUri = Uri.parse('fb://profile/$slug');
          if (await canLaunchUrl(nativeUri)) {
            await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return;
      }

      // ── Generic https fallback ──────────────────────────────────────────────
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // ============================================================================
    // GLASS CARD
    // ============================================================================
    class GlassCard extends StatefulWidget {
      const GlassCard({
        super.key,
        required this.child,
        this.borderRadius = 18.0,
        this.onTap,
        this.padding = const EdgeInsets.all(16),
        this.blur = 16.0,
        this.margin = EdgeInsets.zero,
        this.hasBorder = true,
      });

      final Widget child;
      final double borderRadius;
      final VoidCallback? onTap;
      final EdgeInsetsGeometry padding;
      final double blur;
      final EdgeInsetsGeometry margin;
      final bool hasBorder;

      @override
      State<GlassCard> createState() => _GlassCardState();
    }

    class _GlassCardState extends State<GlassCard>
        with SingleTickerProviderStateMixin {
      late AnimationController _ctrl;
      late Animation<double> _scale;

      @override
      void initState() {
        super.initState();
        _ctrl = AnimationController(
            vsync: this, duration: const Duration(milliseconds: 180));
        _scale = Tween<double>(begin: 1.0, end: 0.98)
            .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      }

      @override
      void dispose() {
        _ctrl.dispose();
        super.dispose();
      }

      void _down(TapDownDetails _) {
        if (widget.onTap == null) return;
        HapticFeedback.lightImpact();
        _ctrl.forward();
      }

      void _up(TapUpDetails _) {
        if (widget.onTap == null) return;
        _ctrl.reverse();
      }

      void _cancel() {
        if (widget.onTap == null) return;
        _ctrl.reverse();
      }

      @override
      Widget build(BuildContext context) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: GestureDetector(
              onTapDown: _down,
              onTapUp: _up,
              onTapCancel: _cancel,
              onTap: widget.onTap,
              child: Container(
                margin: widget.margin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter:
                    ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: widget.hasBorder
                            ? Border.all(
                            color: Colors.white.withOpacity(0.15), width: 0.8)
                            : null,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // ============================================================================
    // SVG ICON WIDGET
    // ============================================================================
    class _SvgIcon extends StatelessWidget {
      final String svgPath;
      final double size;
      const _SvgIcon(this.svgPath, {this.size = 20});

      @override
      Widget build(BuildContext context) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _SvgPainter(svgPath, size)),
        );
      }
    }

    class _SvgPainter extends CustomPainter {
      final String id;
      final double size;
      const _SvgPainter(this.id, this.size);

      @override
      void paint(Canvas canvas, Size sz) {
        final paint = Paint()
          ..color = Colors.white.withOpacity(0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final s = sz.width / 24;

        switch (id) {
          case 'location':
            final pin = Path()
              ..moveTo(12 * s, 22 * s)
              ..cubicTo(12 * s, 22 * s, 5 * s, 15 * s, 5 * s, 10 * s)
              ..cubicTo(5 * s, 6.1 * s, 8.1 * s, 3 * s, 12 * s, 3 * s)
              ..cubicTo(15.9 * s, 3 * s, 19 * s, 6.1 * s, 19 * s, 10 * s)
              ..cubicTo(19 * s, 15 * s, 12 * s, 22 * s, 12 * s, 22 * s)
              ..close();
            canvas.drawPath(pin, paint);
            canvas.drawCircle(Offset(12 * s, 10 * s), 2.5 * s, paint);
            break;

          case 'time':
            canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, paint);
            final hands = Path()
              ..moveTo(12 * s, 7 * s)
              ..lineTo(12 * s, 12 * s)
              ..lineTo(16 * s, 14.5 * s);
            canvas.drawPath(hands, paint);
            break;

          case 'phone':
            final phone = Path()
              ..moveTo(7 * s, 4 * s)
              ..cubicTo(7 * s, 4 * s, 5 * s, 3.5 * s, 4 * s, 5 * s)
              ..cubicTo(3.5 * s, 6 * s, 3 * s, 8 * s, 5.5 * s, 12.5 * s)
              ..cubicTo(8 * s, 17 * s, 11 * s, 20 * s, 15.5 * s, 21.5 * s)
              ..cubicTo(17 * s, 22 * s, 18.5 * s, 21.5 * s, 19.5 * s, 20.5 * s)
              ..cubicTo(20.5 * s, 19.5 * s, 21 * s, 18 * s, 20 * s, 17 * s)
              ..lineTo(16.5 * s, 14.5 * s)
              ..cubicTo(15.5 * s, 13.5 * s, 14.5 * s, 13.5 * s, 14 * s, 14.5 * s)
              ..lineTo(13 * s, 16 * s)
              ..cubicTo(12 * s, 16.5 * s, 10.5 * s, 16 * s, 9.5 * s, 15 * s)
              ..cubicTo(8.5 * s, 14 * s, 8 * s, 12.5 * s, 8.5 * s, 11.5 * s)
              ..lineTo(10 * s, 10.5 * s)
              ..cubicTo(11 * s, 10 * s, 11 * s, 9 * s, 10 * s, 8 * s)
              ..lineTo(7.5 * s, 4.5 * s)
              ..close();
            canvas.drawPath(phone, paint);
            break;

          case 'whatsapp':
            final bg = Path()
              ..moveTo(12 * s, 2 * s)
              ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
              ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
              ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
              ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
              ..close();
            canvas.drawPath(bg, paint);
            final msg = Path()
              ..moveTo(7 * s, 7 * s)
              ..lineTo(17 * s, 7 * s)
              ..lineTo(17 * s, 14 * s)
              ..lineTo(10 * s, 14 * s)
              ..lineTo(7 * s, 17 * s)
              ..lineTo(7 * s, 7 * s)
              ..close();
            canvas.drawPath(msg, paint);
            break;

          case 'email':
            final rect = Rect.fromLTWH(3 * s, 5 * s, 18 * s, 14 * s);
            canvas.drawRRect(
                RRect.fromRectAndRadius(rect, Radius.circular(2 * s)), paint);
            final line = Path()
              ..moveTo(3 * s, 5 * s)
              ..lineTo(12 * s, 13 * s)
              ..lineTo(21 * s, 5 * s);
            canvas.drawPath(line, paint);
            break;

          case 'instagram':
            final outer = Path()
              ..moveTo(12 * s, 3 * s)
              ..cubicTo(7 * s, 3 * s, 3 * s, 7 * s, 3 * s, 12 * s)
              ..cubicTo(3 * s, 17 * s, 7 * s, 21 * s, 12 * s, 21 * s)
              ..cubicTo(17 * s, 21 * s, 21 * s, 17 * s, 21 * s, 12 * s)
              ..cubicTo(21 * s, 7 * s, 17 * s, 3 * s, 12 * s, 3 * s)
              ..close();
            canvas.drawPath(outer, paint);
            canvas.drawCircle(Offset(12 * s, 12 * s), 3.5 * s, paint);
            canvas.drawCircle(Offset(17 * s, 7 * s), 1.2 * s,
                paint..style = PaintingStyle.fill);
            paint.style = PaintingStyle.stroke;
            break;

          case 'facebook':
            final fb = Path()
              ..moveTo(12 * s, 2 * s)
              ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
              ..cubicTo(2 * s, 17 * s, 5.6 * s, 20.8 * s, 10.5 * s, 21.5 * s)
              ..lineTo(10.5 * s, 15.5 * s)
              ..lineTo(7.5 * s, 15.5 * s)
              ..lineTo(7.5 * s, 12.5 * s)
              ..lineTo(10.5 * s, 12.5 * s)
              ..lineTo(10.5 * s, 10 * s)
              ..cubicTo(
                  10.5 * s, 7.8 * s, 12.1 * s, 6.5 * s, 14 * s, 6.5 * s)
              ..cubicTo(14.9 * s, 6.5 * s, 15.8 * s, 6.6 * s, 16.5 * s, 6.7 * s)
              ..lineTo(16.5 * s, 9.5 * s)
              ..lineTo(15.2 * s, 9.5 * s)
              ..cubicTo(14.2 * s, 9.5 * s, 14 * s, 10, 14 * s, 10.8 * s)
              ..lineTo(14 * s, 12.5 * s)
              ..lineTo(16.4 * s, 12.5 * s)
              ..lineTo(16.1 * s, 15.5 * s)
              ..lineTo(14 * s, 15.5 * s)
              ..lineTo(14 * s, 21.7 * s)
              ..cubicTo(
                  19.2 * s, 21.1 * s, 22 * s, 17.2 * s, 22 * s, 12 * s)
              ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
              ..close();
            canvas.drawPath(fb, paint);
            break;

          case 'edit':
            final pen = Path()
              ..moveTo(16 * s, 3 * s)
              ..lineTo(20 * s, 7 * s)
              ..lineTo(9 * s, 18 * s)
              ..lineTo(4 * s, 19 * s)
              ..lineTo(5 * s, 14 * s)
              ..close();
            canvas.drawPath(pen, paint);
            canvas.drawLine(
                Offset(15 * s, 4 * s), Offset(19 * s, 8 * s), paint);
            break;

          case 'map':
            final globe = Path()
              ..moveTo(12 * s, 2 * s)
              ..cubicTo(6.5 * s, 2 * s, 2 * s, 6.5 * s, 2 * s, 12 * s)
              ..cubicTo(2 * s, 17.5 * s, 6.5 * s, 22 * s, 12 * s, 22 * s)
              ..cubicTo(17.5 * s, 22 * s, 22 * s, 17.5 * s, 22 * s, 12 * s)
              ..cubicTo(22 * s, 6.5 * s, 17.5 * s, 2 * s, 12 * s, 2 * s)
              ..close();
            canvas.drawPath(globe, paint);
            final pin = Path()
              ..moveTo(12 * s, 18 * s)
              ..cubicTo(12 * s, 18 * s, 8 * s, 13 * s, 8 * s, 10 * s)
              ..cubicTo(8 * s, 7.8 * s, 9.8 * s, 6 * s, 12 * s, 6 * s)
              ..cubicTo(14.2 * s, 6 * s, 16 * s, 7.8 * s, 16 * s, 10 * s)
              ..cubicTo(16 * s, 13 * s, 12 * s, 18 * s, 12 * s, 18 * s)
              ..close();
            canvas.drawPath(pin, paint);
            canvas.drawCircle(Offset(12 * s, 10 * s), 1.5 * s, paint);
            break;
        }
      }

      @override
      bool shouldRepaint(covariant _SvgPainter old) => old.id != id;
    }

    double _sin(double x) {
      x = x % (2 * 3.14159265358979);
      double result = x;
      double term = x;
      for (int n = 1; n <= 7; n++) {
        term *= -x * x / ((2 * n) * (2 * n + 1));
        result += term;
      }
      return result;
    }

    double _cos(double x) {
      x = x % (2 * 3.14159265358979);
      double result = 1;
      double term = 1;
      for (int n = 1; n <= 7; n++) {
        term *= -x * x / ((2 * n - 1) * (2 * n));
        result += term;
      }
      return result;
    }

    // ============================================================================
    // CONTACT PAGE
    // ============================================================================
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

      // Google Map controller for optional future use
      GoogleMapController? _mapController;

      static const LatLng _officeLocation = LatLng(25.277789, 55.346793);

      Future<void> _refresh() async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() {});
      }

      void _openGoogleMaps() {
        final url = 'https://www.google.com/maps/search/?api=1&query=${_officeLocation.latitude},${_officeLocation.longitude}';
        _launch(url);
      }

      @override
      void dispose() {
        _nameController.dispose();
        _emailController.dispose();
        _phoneController.dispose();
        _messageController.dispose();
        super.dispose();
      }

      InputDecoration _inputDecoration(String label) {
        return InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          floatingLabelStyle: const TextStyle(color: Colors.white70),
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
              backgroundColor: Colors.black87,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  result['message'] ?? 'Failed to send message. Please try again.'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      Widget _contactRow({
        required String svgId,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool showDivider = true,
      }) {
        return Column(
          children: [
            GlassCard(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: onTap,
              child: Row(
                children: [
                  _SvgIcon(svgId, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.60))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.4), size: 20),
                ],
              ),
            ),
            if (showDivider) const SizedBox(height: 8),
          ],
        );
      }

      @override
      Widget build(BuildContext context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom + 30;

        return GradientScaffold(
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.10),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _buildTitleBar()),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverPadding(
                  padding:
                  EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Address
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SvgIcon('location', size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Medco Contracting L.L.C',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Al Andalus Building, Abu Hail Road,\nDeira, Dubai, UAE — PO Box 10839',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.60),
                                        height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Working hours
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SvgIcon('time', size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Working Hours',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 6),
                                  _hoursRow(
                                      'Sun – Thu', '08:30 AM – 08:00 PM', false),
                                  const SizedBox(height: 3),
                                  _hoursRow(
                                      'Friday', '08:30 AM – 07:00 PM', false),
                                  const SizedBox(height: 3),
                                  _hoursRow('Saturday', 'Closed', true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Contact channels ─────────────────────────────────
                      _contactRow(
                        svgId: 'phone',
                        title: 'Call',
                        subtitle: '800 5773',
                        onTap: () => _launch('tel:8005773'),
                      ),
                      _contactRow(
                        svgId: 'whatsapp',
                        title: 'WhatsApp',
                        subtitle: '+971 50 345 5855',
                        onTap: () => _launch('https://wa.me/971503455855'),
                      ),
                      _contactRow(
                        svgId: 'email',
                        title: 'Email',
                        subtitle: 'info@medco-maintanance.com',
                        onTap: () =>
                            _launch('mailto:info@medco-maintanance.com'),
                      ),
                      _contactRow(
                        svgId: 'instagram',
                        title: 'Instagram',
                        subtitle: '@medcocontracting',
                        onTap: () => _launch(
                            'https://www.instagram.com/medcocontracting/'),
                      ),
                      _contactRow(
                        svgId: 'facebook',
                        title: 'Facebook',
                        subtitle: '@medcocontracting',
                        onTap: () =>
                            _launch('https://facebook.com/medcocontracting'),
                        showDivider: false,
                      ),
                      const SizedBox(height: 8),

                      // Map with Open in Google Maps button
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: Row(
                                children: [
                                  _SvgIcon('map', size: 22),
                                  const SizedBox(width: 14),
                                  const Text('Find Us on Map',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: GoogleMap(
                                initialCameraPosition: const CameraPosition(
                                  target: _officeLocation,
                                  zoom: 14,
                                ),
                                markers: {
                                  const Marker(
                                    markerId: MarkerId('office'),
                                    position: _officeLocation,
                                    infoWindow: InfoWindow(title: 'Medco Contracting'),
                                  ),
                                },
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                                // Allow all gestures (pan, zoom, tilt, rotate)
                                gestureRecognizers: const {},
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: GlassCard(
                                borderRadius: 12,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                onTap: _openGoogleMaps,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map_outlined,
                                        size: 18, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    const Text('Open in Google Maps',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Contact form
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _SvgIcon('edit', size: 22),
                                const SizedBox(width: 14),
                                const Text('Contact Form',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration:
                                    _inputDecoration('Your Name'),
                                    validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Please enter your name'
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration:
                                    _inputDecoration('Email Address'),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Email required'
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _phoneController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration:
                                    _inputDecoration('Mobile Number'),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _messageController,
                                    maxLines: 4,
                                    style: const TextStyle(color: Colors.white),
                                    decoration:
                                    _inputDecoration('Your Message'),
                                    validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Please enter your message'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  GlassCard(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 15),
                                    onTap:
                                    _isSending ? null : _sendMessage,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        if (_isSending)
                                          const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white70,
                                            ),
                                          )
                                        else ...[
                                          const Icon(Icons.send_rounded,
                                              color: Colors.white70, size: 18),
                                          const SizedBox(width: 10),
                                          const Text('Send Message',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white70)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Widget _buildTitleBar() {
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: const Text(
              'Contact Us',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
          ),
        );
      }

      Widget _hoursRow(String day, String hours, bool isRed) {
        return Row(
          children: [
            Text(day,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isRed
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.60))),
            const SizedBox(width: 8),
            Text(hours,
                style: TextStyle(
                    fontSize: 13,
                    color: isRed
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.45))),
          ],
        );
      }
    }