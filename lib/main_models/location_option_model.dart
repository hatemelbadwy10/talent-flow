class LocationOptionModel {
  const LocationOptionModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory LocationOptionModel.fromJson(Map<String, dynamic> json) {
    return LocationOptionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
