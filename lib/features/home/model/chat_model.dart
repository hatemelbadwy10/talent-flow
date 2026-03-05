class ChatModel {
    ChatModel({
        required this.id,
        required this.contractId,
        required this.hasContract,
        required this.receiver,
        required this.messages,
    });

    final int? id;
    final dynamic contractId;
    final bool? hasContract;
    final Receiver? receiver;
    final List<Message> messages;

    ChatModel copyWith({
        int? id,
        int? contractId,
        bool? hasContract,
        Receiver? receiver,
        List<Message>? messages,
    }) {
        return ChatModel(
            id: id ?? this.id,
            contractId: contractId ?? this.contractId,
            hasContract: hasContract ?? this.hasContract,
            receiver: receiver ?? this.receiver,
            messages: messages ?? this.messages,
        );
    }

    factory ChatModel.fromJson(Map<String, dynamic> json){ 
        return ChatModel(
            id: json["id"],
            contractId: json["contract_id"],
            hasContract: json["has_contract"],
            receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
            messages: json["messages"] == null ? [] : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
        );
    }

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
        return Message(
            id: json["id"],
            messageType: json["message_type"],
            message: json["message"],
            isSent: json["is_sent"],
            sender: json["sender"] == null ? null : Receiver.fromJson(json["sender"]),
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            time: json["time"],
            status: json["status"],
        );
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
