import 'package:talent_flow/data/config/mapper.dart';

class HomeModel extends SingleMapper {
  HomeModel({
    required this.cards,
    required this.top,
    required this.categories,
  });

  final List<Card> cards;
  final Top? top;
  final List<Category> categories;

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      cards: json["cards"] == null
          ? []
          : List<Card>.from(json["cards"]!.map((x) => Card.fromJson(x))),
      top: json["top"] == null ? null : Top.fromJson(json["top"]),
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return HomeModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class Card extends SingleMapper {
  Card({
    required this.id,
    required this.title,
    required this.image,
  });

  final int? id;
  final String? title;
  final String? image;

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json["id"],
      title: json["title"],
      image: json["image"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Card.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class Category extends SingleMapper {
  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final int? id;
  final String? name;
  final String? description;
  final String? icon;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      icon: json["icon"],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class Top extends SingleMapper {
  Top({
    required this.type,
    required this.items,
  });

  final String? type;
  final List<dynamic> items;

  factory Top.fromJson(Map<String, dynamic> json) {
    return Top(
      type: json["type"],
      items: json["items"] == null
          ? []
          : List<dynamic>.from(json["items"]!.map((x) => x)),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Top.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
