import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/core/app_storage_keys.dart';
import '../api/end_points.dart';

class PusherService {
  PusherService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final PusherChannelsFlutter _client = PusherChannelsFlutter.getInstance();
  final SharedPreferences _sharedPreferences;

  bool _isInitialized = false;
  bool _isConnected = false;

  static const String _appKey = '62c38f3acabe2fa4b92e';
  static const String _cluster = 'mt1';
  static const String _scheme = 'https';
  static final List<String> _authEndpoints = [
    Uri.parse(EndPoints.baseUrl).resolve('api/broadcasting/auth').toString(),
    Uri.parse(EndPoints.baseUrl).resolve('broadcasting/auth').toString(),
  ];

  String chatChannel(int conversationId) => 'private-chat.$conversationId';
  String userChannel(int userId) => 'private-user.$userId';

  Future<void> init() async {
    if (_isInitialized) {
      _logPusher('init skipped', {'reason': 'already_initialized'});
      return;
    }

    _logPusher(
      'init start',
      {
        'cluster': _cluster,
        'useTLS': _scheme == 'https',
        'authEndpoints': _authEndpoints,
      },
    );

    await _client.init(
      apiKey: _appKey,
      cluster: _cluster,
      useTLS: _scheme == 'https',
      onAuthorizer: _authorizeChannel,
      onConnectionStateChange: (currentState, previousState) {
        log(
          'Pusher connection: $previousState -> $currentState',
          name: 'PusherService',
        );
      },
      onSubscriptionSucceeded: (channelName, data) {
        _logPusher(
          'subscription succeeded',
          {
            'channelName': channelName,
            'dataPreview': _preview(data),
          },
        );
      },
      onSubscriptionError: (message, error) {
        _logPusher(
          'subscription error',
          {
            'message': message,
            'error': error?.toString(),
          },
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
    _logPusher('init success');
  }

  Future<void> connect() async {
    await init();
    if (_isConnected) {
      _logPusher('connect skipped', {'reason': 'already_connected'});
      return;
    }

    _logPusher('connect start');
    await _client.connect();
    _isConnected = true;
    _logPusher('connect completed');
  }

  Future<void> disconnect() async {
    if (!_isConnected) {
      _logPusher('disconnect skipped', {'reason': 'already_disconnected'});
      return;
    }

    _logPusher('disconnect start');
    await _client.disconnect();
    _isConnected = false;
    _logPusher('disconnect completed');
  }

  Future<void> subscribe({
    required String channelName,
    required Function(dynamic event) onEvent,
  }) async {
    await connect();
    _logPusher('subscribe start', {'channelName': channelName});

    await _client.subscribe(
      channelName: channelName,
      onEvent: (event) {
        final dynamic rawEvent = event;
        _logPusher(
          'event received',
          {
            'channelName': rawEvent.channelName,
            'eventName': rawEvent.eventName,
            'dataType': rawEvent.data.runtimeType.toString(),
            'dataPreview': _preview(rawEvent.data),
          },
        );
        onEvent(event);
      },
    );
    _logPusher('subscribe completed', {'channelName': channelName});
  }

  Future<void> unsubscribe(String channelName) async {
    _logPusher('unsubscribe start', {'channelName': channelName});
    await _client.unsubscribe(channelName: channelName);
    _logPusher('unsubscribe completed', {'channelName': channelName});
  }

  Future<dynamic> _authorizeChannel(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    final token =
        _sharedPreferences.getString(AppStorageKey.token)?.trim() ?? '';
    final dio = Dio(
      BaseOptions(
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    _logPusher(
      'authorizer request',
      {
        'channelName': channelName,
        'socketId': socketId,
        'authEndpoints': _authEndpoints,
        'hasToken': token.isNotEmpty,
      },
    );

    for (final endpoint in _authEndpoints) {
      try {
        final response = await dio.post(
          endpoint,
          data: {
            'socket_id': socketId,
            'channel_name': channelName,
          },
        );

        final payload = _normalizeAuthPayload(response.data);

        _logPusher(
          'authorizer response',
          {
            'channelName': channelName,
            'endpoint': endpoint,
            'statusCode': response.statusCode,
            'dataPreview': _preview(response.data),
            'normalizedKeys': payload?.keys.toList(),
          },
        );

        if (payload != null) {
          return payload;
        }
      } on DioException catch (error) {
        _logPusher(
          'authorizer dio error',
          {
            'channelName': channelName,
            'endpoint': endpoint,
            'statusCode': error.response?.statusCode,
            'responsePreview': _preview(error.response?.data),
            'message': error.message,
          },
        );
      } catch (error) {
        _logPusher(
          'authorizer unexpected error',
          {
            'channelName': channelName,
            'endpoint': endpoint,
            'error': error.toString(),
          },
        );
      }
    }

    return null;
  }

}

Map<String, String>? _normalizeAuthPayload(dynamic raw) {
  dynamic value = raw;

  if (value is String && value.trim().isNotEmpty) {
    try {
      value = jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  if (value is! Map) {
    return null;
  }

  final map = value.map((key, val) => MapEntry(key.toString(), val));
  final auth = map['auth']?.toString().trim() ?? '';
  if (auth.isEmpty) {
    return null;
  }

  return {
    'auth': auth,
    if (map['channel_data'] != null)
      'channel_data': map['channel_data'].toString(),
    if (map['shared_secret'] != null)
      'shared_secret': map['shared_secret'].toString(),
  };
}

void _logPusher(String message, [Map<String, Object?> details = const {}]) {
  final suffix = details.isEmpty ? '' : ' | $details';
  log('[PusherService] $message$suffix', name: 'PusherService');
}

String _preview(dynamic value, {int max = 220}) {
  final text = value?.toString() ?? 'null';
  if (text.length <= max) {
    return text;
  }
  return '${text.substring(0, max)}…';
}
