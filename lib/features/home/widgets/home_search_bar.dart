import 'dart:async';
import 'package:flutter/material.dart';
import '../shared/home_constants.dart';

class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  // Typewriter animation parameters
  final List<String> _hintKeywords = [
    'Painter',
    'Handyman',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Cleaner',
  ];

  String _currentHint = '';
  int _keywordIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;
  Timer? _typeTimer;

  // Cursor blinking
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _startCursorBlink();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    _typeTimer?.cancel();
    const typingSpeed = Duration(milliseconds: 50);
    const pauseDuration = Duration(seconds: 1);

    _typeTimer = Timer.periodic(typingSpeed, (timer) {
      if (_isDeleting) {
        if (_charIndex > 0) {
          _charIndex--;
          setState(() {
            _currentHint = _hintKeywords[_keywordIndex].substring(0, _charIndex);
          });
        } else {
          _isDeleting = false;
          _keywordIndex = (_keywordIndex + 1) % _hintKeywords.length;
          timer.cancel();
          Future.delayed(pauseDuration ~/ 2, () => _startTypewriter());
        }
      } else {
        final fullKeyword = _hintKeywords[_keywordIndex];
        if (_charIndex < fullKeyword.length) {
          _charIndex++;
          setState(() {
            _currentHint = fullKeyword.substring(0, _charIndex);
          });
        } else {
          _isDeleting = true;
          timer.cancel();
          Future.delayed(pauseDuration, () => _startTypewriter());
        }
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    final showPlaceholder = widget.controller.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? kPrimary.withValues(alpha: 0.70) : Colors.grey.withValues(alpha: 0.20),
            width: focused ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: focused ? kPrimary.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
              blurRadius: focused ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Actual TextField
            TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: const TextStyle(color: kTextDark, fontSize: 15),
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: '', // No static hint – we overlay it
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: focused ? kPrimary : kTextLight,
                  size: 22,
                ),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: widget.onClear,
                  child: Icon(Icons.close_rounded,
                      color: focused ? kPrimary : kTextLight, size: 20),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 4),
              ),
            ),
            // Animated placeholder overlay (only when text is empty)
            if (showPlaceholder)
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(left: 48), // space for prefix icon
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentHint,
                        style: const TextStyle(color: kTextLight, fontSize: 15),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _showCursor ? '|' : ' ',
                        style: const TextStyle(color: kPrimary, fontSize: 15, fontWeight: FontWeight.w500),
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