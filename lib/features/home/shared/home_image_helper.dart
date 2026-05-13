import 'dart:convert';
import 'package:flutter/material.dart';

final Map<String, ImageProvider> imageCache = {};

ImageProvider resolveImage(String src) {
  if (imageCache.containsKey(src)) return imageCache[src]!;
  ImageProvider p;
  if (src.startsWith('http://') || src.startsWith('https://')) {
    p = NetworkImage(src);
  } else if (src.startsWith('data:image')) {
    try {
      p = MemoryImage(base64Decode(src.split(',').last));
    } catch (_) {
      p = const NetworkImage('');
    }
  } else {
    p = NetworkImage('http://admin.medco-contracting.com$src');
  }
  imageCache[src] = p;
  return p;
}

class HomeCachedImage extends StatelessWidget {
  final String? src;
  final BoxFit fit;
  final Widget fallback;

  const HomeCachedImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) return fallback;
    return Image(
      image: resolveImage(src!),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, error, stackTrace) => fallback,
    );
  }
}