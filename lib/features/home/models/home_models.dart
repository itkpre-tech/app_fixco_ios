// lib/features/home/models/home_models.dart

class Service {
  final String id;
  final String name;
  final String image;

  const Service({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
    id: j['id'].toString(),
    name: j['name'] as String? ?? '',
    image: j['image'] as String? ?? '',
  );
}

class Project {
  final String id;
  final String title;
  final String coverImage;
  final List<dynamic> gallery;

  const Project({
    required this.id,
    required this.title,
    required this.coverImage,
    this.gallery = const [],
  });

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'].toString(),
    title: j['title'] as String? ?? '',
    coverImage: j['cover_image'] as String? ?? '',
    gallery: j['gallery'] as List<dynamic>? ?? const [],
  );
}

class Offer {
  final String id;
  final String title;
  final String description;
  final String image;
  final int isActive;
  final String? endDateFormatted;
  final int? daysLeft;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
    this.endDateFormatted,
    this.daysLeft,
  });

  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
    id: j['id']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    image: j['image']?.toString() ?? '',
    isActive: j['is_active'] as int? ?? 0,
    endDateFormatted: j['end_date_formatted']?.toString(),
    daysLeft: j['days_left'] as int?,
  );
}