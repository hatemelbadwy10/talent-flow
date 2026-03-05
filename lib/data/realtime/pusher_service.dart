import 'dart:developer';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  PusherService();

  final PusherChannelsFlutter _client = PusherChannelsFlutter.getInstance();

  bool _isInitialized = false;
  bool _isConnected = false;

  static const String _appKey = '62c38f3acabe2fa4b92e';
  static const String _cluster = 'mt1';
  static const String _scheme = 'https';

  String chatChannel(int conversationId) => 'chat.$conversationId';
  String userChannel(int userId) => 'user.$userId';

  Future<void> init() async {
    if (_isInitialized) return;

    await _client.init(
      apiKey: _appKey,
      cluster: _cluster,
      useTLS: _scheme == 'https',
      onConnectionStateChange: (currentState, previousState) {
        log(
          'Pusher connection: $previousState -> $currentState',
          name: 'PusherService',
        );
      },
      onError: (message, code, error) {
        log(
          'Pusher error: $message | code: $code | error: $error',
          name: 'PusherService',
        );
      },
    );

    _isInitialized = true;
  }

  Future<void> connect() async {
    await init();
    if (_isConnected) return;

    await _client.connect();
    _isConnected = true;
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;

    await _client.disconnect();
    _isConnected = false;
  }

  Future<void> subscribe({
    required String channelName,
  required Function(dynamic event) onEvent,
  }) async {
    await connect();

    await _client.subscribe(
      channelName: channelName,
      onEvent: onEvent,
    );
  }

  Future<void> unsubscribe(String channelName) async {
    await _client.unsubscribe(channelName: channelName);
  }
}
