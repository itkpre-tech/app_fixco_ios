// Shared Service model used across home.dart and home_service_booking.dart
class Service {
  final String id;
  final String name;
  final String image;
  final String description;
  final String price;

  Service({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
    id: j['id'].toString(),
    name: j['name'] ?? '',
    image: j['image'] ?? '',
    description: j['description'] ?? '',
    price: j['price']?.toString() ?? '',
  );
}