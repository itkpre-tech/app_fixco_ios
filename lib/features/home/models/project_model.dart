class ProjectModel {
  final String id;
  final String title;
  final String coverImage;
  final List<dynamic> gallery;

  ProjectModel({
    required this.id,
    required this.title,
    required this.coverImage,
    this.gallery = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
    id:          j['id'].toString(),
    title:       j['title']       ?? '',
    coverImage:  j['cover_image'] ?? '',
    gallery:     j['gallery']     ?? [],
  );
}