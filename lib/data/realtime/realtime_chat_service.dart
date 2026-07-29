abstract interface class RealtimeChatService {
  String chatChannel(int conversationId);

  Future<void> subscribe({
    required String channelName,
    required void Function(dynamic event) onEvent,
  });

  Future<void> unsubscribe(String channelName);
}
