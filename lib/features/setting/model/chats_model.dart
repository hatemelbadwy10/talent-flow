
import 'package:talent_flow/data/config/mapper.dart';

class ChatsModel implements Mapper{
    ChatsModel({
        required this.id,
        required this.receiver,
        required this.unreadCount,
        required this.lastMessageSnippet,
        required this.since,
        required this.date,
    });

    final int? id;
    final Receiver? receiver;
    final int? unreadCount;
    final String? lastMessageSnippet;
    final String? since;
    final DateTime? date;

    ChatsModel copyWith({
        int? id,
        Receiver? receiver,
        int? unreadCount,
        String? lastMessageSnippet,
        String? since,
        DateTime? date,
    }) {
        return ChatsModel(
            id: id ?? this.id,
            receiver: receiver ?? this.receiver,
            unreadCount: unreadCount ?? this.unreadCount,
            lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
            since: since ?? this.since,
            date: date ?? this.date,
        );
    }

    factory ChatsModel.fromJson(Map<String, dynamic> json){ 
        return ChatsModel(
            id: json["id"],
            receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
            unreadCount: json["unread_count"],
            lastMessageSnippet: json["last_message_snippet"],
            since: json["since"],
            date: DateTime.tryParse(json["date"] ?? ""),
        );
    }
    
      @override
      Map<String, dynamic> toJson() {
        return {
          "id": id,
          "unread_count": unreadCount,
          "last_message_snippet": lastMessageSnippet,
          "since": since,
          "date": date?.toIso8601String(),
        };
      }

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

    factory Receiver.fromJson(Map<String, dynamic> json){ 
        return Receiver(
            id: json["id"],
            name: json["name"],
            image: json["image"],
            jobTitle: json["job_title"],
        );
    }

}
