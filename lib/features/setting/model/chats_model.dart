import 'package:talent_flow/data/config/mapper.dart';

class ChatsModel implements Mapper {
  ChatsModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.contractId,
    required this.hasContract,
    required this.receiver,
    required this.unreadCount,
    required this.lastMessageSnippet,
    required this.since,
    required this.date,
  });

  final int? id;
  final int? projectId;
  final String? projectTitle;
  final int? contractId;
  final bool? hasContract;
  final Receiver? receiver;
  final int? unreadCount;
  final String? lastMessageSnippet;
  final String? since;
  final DateTime? date;

  static int compareNewestFirst(ChatsModel a, ChatsModel b) {
    final aDate = a.date;
    final bDate = b.date;
    if (aDate != null && bDate != null) {
      final dateComparison = bDate.compareTo(aDate);
      if (dateComparison != 0) return dateComparison;
    } else if (aDate != null) {
      return -1;
    } else if (bDate != null) {
      return 1;
    }

    final aAge = _parseRelativeAge(a.since);
    final bAge = _parseRelativeAge(b.since);
    if (aAge != null && bAge != null) {
      final ageComparison = aAge.compareTo(bAge);
      if (ageComparison != 0) return ageComparison;
    } else if (aAge != null) {
      return -1;
    } else if (bAge != null) {
      return 1;
    }

    return (b.id ?? -1).compareTo(a.id ?? -1);
  }

  ChatsModel copyWith({
    int? id,
    int? projectId,
    String? projectTitle,
    int? contractId,
    bool? hasContract,
    Receiver? receiver,
    int? unreadCount,
    String? lastMessageSnippet,
    String? since,
    DateTime? date,
  }) {
    return ChatsModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      contractId: contractId ?? this.contractId,
      hasContract: hasContract ?? this.hasContract,
      receiver: receiver ?? this.receiver,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
      since: since ?? this.since,
      date: date ?? this.date,
    );
  }

  factory ChatsModel.fromJson(Map<String, dynamic> json) {
    return ChatsModel(
      id: json["id"],
      projectId: _parseInt(json["project_id"]),
      projectTitle: json["project_title"]?.toString(),
      contractId: _parseInt(json["contract_id"]),
      hasContract: _toBool(json["has_contract"]),
      receiver:
          json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
      unreadCount: json["unread_count"],
      lastMessageSnippet: json["last_message_snippet"],
      since: json["since"],
      date: _parseLastMessageDate(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "project_id": projectId,
      "project_title": projectTitle,
      "contract_id": contractId,
      "has_contract": hasContract,
      "unread_count": unreadCount,
      "last_message_snippet": lastMessageSnippet,
      "since": since,
      "date": date?.toIso8601String(),
    };
  }
}

DateTime? _parseLastMessageDate(Map<String, dynamic> json) {
  final lastMessage = json["last_message"];
  final candidates = [
    json["last_message_at"],
    if (lastMessage is Map) lastMessage["created_at"],
    if (lastMessage is Map) lastMessage["updated_at"],
    json["updated_at"],
    json["date"],
  ];

  for (final candidate in candidates) {
    final parsed = DateTime.tryParse(candidate?.toString() ?? "");
    if (parsed != null) return parsed;
  }
  return null;
}

Duration? _parseRelativeAge(String? value) {
  var text = value?.trim().toLowerCase() ?? "";
  if (text.isEmpty) return null;

  text = _normalizeArabicDigits(text);
  if (text.contains("الآن") ||
      text.contains("لحظ") ||
      text.contains("now") ||
      text.contains("just")) {
    return Duration.zero;
  }

  final number = int.tryParse(RegExp(r"\d+").firstMatch(text)?.group(0) ?? "");
  final quantity = number ?? _relativeWordQuantity(text);

  if (text.contains("دقيق") || text.contains("minute")) {
    return Duration(minutes: quantity);
  }
  if (text.contains("ساع") || text.contains("hour")) {
    return Duration(hours: quantity);
  }
  if (text.contains("يوم") || text.contains("day")) {
    return Duration(days: quantity);
  }
  if (text.contains("أسبوع") ||
      text.contains("اسبوع") ||
      text.contains("أسابيع") ||
      text.contains("اسابيع") ||
      text.contains("week")) {
    return Duration(days: quantity * 7);
  }
  if (text.contains("شهر") ||
      text.contains("أشهر") ||
      text.contains("اشهر") ||
      text.contains("month")) {
    return Duration(days: quantity * 30);
  }
  if (text.contains("سن") || text.contains("year")) {
    return Duration(days: quantity * 365);
  }
  return null;
}

int _relativeWordQuantity(String text) {
  if (text.contains("ين") || text.contains("two") || text.contains("couple")) {
    return 2;
  }
  return 1;
}

String _normalizeArabicDigits(String value) {
  const arabicDigits = "٠١٢٣٤٥٦٧٨٩";
  const persianDigits = "۰۱۲۳۴۵۶۷۸۹";
  var result = value;
  for (var index = 0; index < 10; index++) {
    result = result
        .replaceAll(arabicDigits[index], "$index")
        .replaceAll(persianDigits[index], "$index");
  }
  return result;
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

bool? _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return null;
  }
  return normalized == '1' || normalized == 'true' || normalized == 'yes';
}

class Receiver {
  Receiver({
    required this.id,
    required this.name,
    required this.image,
    required this.jobTitle,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? jobTitle;

  Receiver copyWith({
    int? id,
    String? name,
    String? image,
    String? jobTitle,
  }) {
    return Receiver(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      jobTitle: json["job_title"],
    );
  }
}
