class OfferModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final int isActive;
  final String? endDateFormatted;
  final int? daysLeft;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
    this.endDateFormatted,
    this.daysLeft,
  });

  factory OfferModel.fromJson(Map<String, dynamic> j) => OfferModel(
    id:               j['id']?.toString()               ?? '',
    title:            j['title']?.toString()            ?? '',
    description:      j['description']?.toString()      ?? '',
    image:            j['image']?.toString()            ?? '',
    isActive:         j['is_active']                    ?? 0,
    endDateFormatted: j['end_date_formatted']?.toString(),
    daysLeft:         j['days_left'],
  );
}