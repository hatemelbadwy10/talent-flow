class PartnerModel {
  const PartnerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.image,
  });

  final int? id;
  final String name;
  final String description;
  final String url;
  final String image;

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'image': image,
    };
  }
}
