class ResponsePayloadParser {
  const ResponsePayloadParser._();

  static dynamic payload(dynamic data) {
    final normalized = _normalizeMap(data);
    if (!normalized.containsKey('payload')) {
      throw const FormatException('Response payload is missing.');
    }

    final payload = normalized['payload'];
    if (payload == null) {
      throw const FormatException('Response payload is null.');
    }
    return payload;
  }

  static Map<String, dynamic> payloadMap(dynamic data) {
    return _normalizeMap(payload(data));
  }

  static List<dynamic> payloadList(dynamic data) {
    final payloadData = payload(data);
    if (payloadData is List<dynamic>) {
      return payloadData;
    }
    if (payloadData is List) {
      return List<dynamic>.from(payloadData);
    }
    throw const FormatException('Response payload is not a list.');
  }

  static Map<String, dynamic> map(dynamic value) {
    return _normalizeMap(value);
  }

  static List<dynamic> list(dynamic value) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is List) {
      return List<dynamic>.from(value);
    }
    throw const FormatException('Value is not a list.');
  }

  static Map<String, dynamic> _normalizeMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const FormatException('Response body is not a valid map.');
  }
}
