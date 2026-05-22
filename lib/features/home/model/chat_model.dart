class ChatModel {
    ChatModel({
        required this.id,
        required this.projectId,
        required this.contractId,
        required this.hasContract,
        required this.receiver,
        required this.messages,
    });

    final int? id;
    final int? projectId;
    final dynamic contractId;
    final bool? hasContract;
    final Receiver? receiver;
    final List<Message> messages;

    ChatModel copyWith({
        int? id,
        int? projectId,
        int? contractId,
        bool? hasContract,
        Receiver? receiver,
        List<Message>? messages,
    }) {
        return ChatModel(
            id: id ?? this.id,
            projectId: projectId ?? this.projectId,
            contractId: contractId ?? this.contractId,
            hasContract: hasContract ?? this.hasContract,
            receiver: receiver ?? this.receiver,
            messages: messages ?? this.messages,
        );
    }

    factory ChatModel.fromJson(Map<String, dynamic> json){ 
        return ChatModel(
            id: json["id"],
            projectId: _parseInt(json["project_id"]),
            contractId: json["contract_id"],
            hasContract: json["has_contract"],
            receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
            messages: json["messages"] == null ? [] : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
        );
    }

}

int? _parseInt(dynamic value) {
    if (value is int) {
        return value;
    }
    return int.tryParse(value?.toString() ?? "");
}

class Message {
    Message({
        required this.id,
        required this.messageType,
        required this.message,
        required this.isSent,
        required this.sender,
        required this.createdAt,
        required this.time,
        required this.status,
    });

    final int? id;
    final String? messageType;
    final String? message;
    final bool? isSent;
    final Receiver? sender;
    final DateTime? createdAt;
    final String? time;
    final String? status;

    Message copyWith({
        int? id,
        String? messageType,
        String? message,
        bool? isSent,
        Receiver? sender,
        DateTime? createdAt,
        String? time,
        String? status,
    }) {
        return Message(
            id: id ?? this.id,
            messageType: messageType ?? this.messageType,
            message: message ?? this.message,
            isSent: isSent ?? this.isSent,
            sender: sender ?? this.sender,
            createdAt: createdAt ?? this.createdAt,
            time: time ?? this.time,
            status: status ?? this.status,
        );
    }

    factory Message.fromJson(Map<String, dynamic> json){
        final createdAt = DateTime.tryParse(
            _firstNonEmptyText([
                json["created_at"],
                json["updated_at"],
            ]) ?? "",
        );

        return Message(
            id: _parseInt(json["id"]),
            messageType: _firstNonEmptyText([
                json["message_type"],
                json["type"],
                _looksLikeTextPayload(json) ? "text" : null,
            ]),
            message: _firstNonEmptyText([
                json["message"],
                json["body"],
                json["text"],
                json["content"],
            ]),
            isSent: _toBool(json["is_sent"]),
            sender: _parseReceiver(json),
            createdAt: createdAt,
            time: _firstNonEmptyText([
                json["time"],
                json["created_at"],
                json["updated_at"],
            ]),
            status: _firstNonEmptyText([
                json["status"],
                json["state"],
            ]),
        );
    }

}

Receiver? _parseReceiver(Map<String, dynamic> json) {
    final rawSender = json["sender"];
    if (rawSender is Map<String, dynamic>) {
        return Receiver.fromJson(rawSender);
    }
    if (rawSender is Map) {
        return Receiver.fromJson(rawSender.map(
            (key, value) => MapEntry(key.toString(), value),
        ));
    }

    final senderId = _parseInt(json["sender_id"]);
    if (senderId == null) {
        return null;
    }

    return Receiver(
        id: senderId,
        name: null,
        image: null,
        jobTitle: null,
    );
}

String? _firstNonEmptyText(List<dynamic> values) {
    for (final value in values) {
        final text = value?.toString().trim() ?? "";
        if (text.isNotEmpty && text.toLowerCase() != "null") {
            return text;
        }
    }
    return null;
}

bool _toBool(dynamic value) {
    if (value is bool) {
        return value;
    }
    if (value is num) {
        return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? "";
    if (normalized.isEmpty) {
        return false;
    }

    return normalized == "1" ||
        normalized == "true" ||
        normalized == "yes";
}

bool _looksLikeTextPayload(Map<String, dynamic> json) {
    return _firstNonEmptyText([
            json["message"],
            json["body"],
            json["text"],
            json["content"],
        ]) !=
        null;
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
