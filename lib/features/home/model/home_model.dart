import 'package:talent_flow/data/config/mapper.dart';
import 'package:talent_flow/features/home/model/partner_model.dart';

class HomeModel extends SingleMapper {
  HomeModel({
    required this.cards,
    required this.top,
    required this.categories,
    required this.partners,
  });

  final List<Card> cards;
  final Top? top;
  final List<Category> categories;
  final List<PartnerModel> partners;

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
      partners: json["partners"] == null
          ? []
          : List<PartnerModel>.from(
              json["partners"]!.map((x) => PartnerModel.fromJson(x))),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return HomeModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => {
        'cards': cards.map((item) => item.toJson()).toList(growable: false),
        'top': top?.toJson(),
        'categories':
            categories.map((item) => item.toJson()).toList(growable: false),
        'partners':
            partners.map((item) => item.toJson()).toList(growable: false),
      };
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
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
      };
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
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
      };
}

class Top extends SingleMapper {
  Top({
    required this.type,
    required this.items,
  });

  final String? type;
  final List<TopItem> items;

  factory Top.fromJson(Map<String, dynamic> json) {
    return Top(
      type: json["type"],
      items: json["items"] is List
          ? (json["items"] as List)
              .whereType<Map>()
              .map((item) => TopItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return Top.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'items': items.map((item) => item.toJson()).toList(growable: false),
      };
}

final class TopItem {
  const TopItem({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.image,
    required this.rating,
    required this.isInFavorites,
  });

  final int? id;
  final String? name;
  final String? jobTitle;
  final String? image;
  final double? rating;
  final bool isInFavorites;

  factory TopItem.fromJson(Map<String, dynamic> json) {
    return TopItem(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      jobTitle: (json['job_title'] ?? json['jop_title'])?.toString(),
      image: json['image']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      isInFavorites: _toBool(
        json['is_in_favorites'] ?? json['is_fav'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'job_title': jobTitle,
        'image': image,
        'rating': rating,
        'is_in_favorites': isInFavorites,
      };
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool _toBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}
