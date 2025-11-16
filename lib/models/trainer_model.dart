class TrainerModel {
  final String id;
  final String name;
  final String title;
  final String imageUrl;

  TrainerModel({
    required this.id,
    required this.name,
    required this.title,
    this.imageUrl = '',
  });

  factory TrainerModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainerModel(
      id: id,
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  TrainerModel copyWith({
    String? id,
    String? name,
    String? title,
    String? imageUrl,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
