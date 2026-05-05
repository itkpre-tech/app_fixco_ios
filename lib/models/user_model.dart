class UserModel {
  final String id;
  final String name;
  final String email;
  final String? image;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
    );
  }
}