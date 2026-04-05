import 'dart:convert';
import 'dart:developer';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../dio/dio_client.dart';

class PusherService {
  PusherService({required DioClient dioClient}) : _dioClient = dioClient;

  final PusherChannelsFlutter _client = PusherChannelsFlutter.getInstance();
  final DioClient _dioClient;

  bool _isInitialized = false;
  bool _isConnected = false;

  static const String _appKey = '62c38f3acabe2fa4b92e';
  static const String _cluster = 'mt1';
  static const String _scheme = 'https';
  static const List<String> _broadcastAuthEndpoints = <String>[
    'broadcasting/auth',
    'api/broadcasting/auth',
  ];

  String chatChannel(int conversationId) => 'private-chat.$conversationId';
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
      onSubscriptionSucceeded: (channelName, data) {
        log(
          'Pusher subscription succeeded: $channelName | data: $data',
          name: 'PusherService',
        );
      },
      onSubscriptionError: (message, error) {
        log(
          'Pusher subscription error: $message | error: $error',
          name: 'PusherService',
        );
      },
      onError: (message, code, error) {
        log(
          'Pusher error: $message | code: $code | error: $error',
          name: 'PusherService',
        );
      },
      onAuthorizer: _onAuthorizer,
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
    required void Function(PusherEvent event) onEvent,
  }) async {
    await connect();

    await _client.subscribe(
      channelName: channelName,
      onEvent: (dynamic event) {
        if (event is PusherEvent) {
          onEvent(event);
          return;
        }

        log(
          'Pusher event had unexpected type: ${event.runtimeType}',
          name: 'PusherService',
        );
      },
    );
  }

  Future<void> unsubscribe(String channelName) async {
    await _client.unsubscribe(channelName: channelName);
  }

  Future<dynamic> _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    for (final endpoint in _broadcastAuthEndpoints) {
      try {
        final response = await _dioClient.post(
          uri: endpoint,
          data: {
            'socket_id': socketId,
            'channel_name': channelName,
          },
        );

        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }

        if (data is Map) {
          return data.map((key, value) => MapEntry(key.toString(), value));
        }

        if (data is String && data.trim().isNotEmpty) {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          if (decoded is Map) {
            return decoded.map((key, value) => MapEntry(key.toString(), value));
          }
        }

        log(
          'Pusher authorizer returned unexpected response from $endpoint: '
          '${data.runtimeType}',
          name: 'PusherService',
        );
      } catch (error, stackTrace) {
        log(
          'Pusher authorizer failed for $channelName via $endpoint: $error',
          name: 'PusherService',
          stackTrace: stackTrace,
        );
      }
    }

    log(
      'Pusher authorizer could not authenticate $channelName. '
      'Realtime updates are disabled for this channel.',
      name: 'PusherService',
    );
    return <String, dynamic>{};
  }
}
