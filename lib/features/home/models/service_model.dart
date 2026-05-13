class ServiceModel {
  final String id;
  final String name;
  final String image;

  ServiceModel({required this.id, required this.name, required this.image});

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
    id:    j['id'].toString(),
    name:  j['name']  ?? '',
    image: j['image'] ?? '',
  );
}