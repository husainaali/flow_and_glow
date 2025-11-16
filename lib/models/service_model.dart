class ServiceModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String trainer;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.trainer,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      trainer: map['trainer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'trainer': trainer,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? trainer,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      trainer: trainer ?? this.trainer,
    );
  }
}
