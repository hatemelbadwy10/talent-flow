final class RealtimeEvent {
  const RealtimeEvent({
    required this.channelName,
    required this.eventName,
    this.data,
  });

  final String channelName;
  final String eventName;
  final Object? data;
}

abstract interface class RealtimeChatService {
  String chatChannel(int conversationId);

  Future<void> subscribe({
    required String channelName,
    required void Function(RealtimeEvent event) onEvent,
  });

  Future<void> unsubscribe(String channelName);
}
