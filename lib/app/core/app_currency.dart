import 'package:shared_preferences/shared_preferences.dart';

import '../../data/config/di.dart';
import 'app_storage_keys.dart';

abstract class AppCurrency {
  static const String defaultCurrency = 'USD';

  static SharedPreferences get _prefs => sl<SharedPreferences>();

  static String get code {
    final cached = _prefs.getString(AppStorageKey.currency)?.trim();
    if (cached == null || cached.isEmpty) {
      return defaultCurrency;
    }
    return cached;
  }

  static Future<void> cache(String? value) async {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }
    await _prefs.setString(AppStorageKey.currency, normalized);
  }

  static Future<void> cacheFromPayload(dynamic raw) async {
    if (raw == null) {
      return;
    }

    final map = _asMap(raw);
    if (map == null) {
      return;
    }

    final payload = _asMap(map['payload']);
    final user = _asMap(map['user']) ?? _asMap(payload?['user']);

    await cache(
      _firstString([
        map['currency'],
        payload?['currency'],
        user?['currency'],
      ]),
    );
  }

  static String formatAmount(dynamic amount) {
    final text = amount?.toString().trim() ?? '';
    if (text.isEmpty) {
      return code;
    }
    return '$text $code';
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

String? _firstString(List<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}
