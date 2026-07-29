class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.token,
    required this.raw,
  });

  final Map<String, dynamic> user;
  final String token;
  final Map<String, dynamic> raw;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    if (payload is! Map) {
      throw const FormatException('Authentication payload is missing');
    }

    final user = payload['user'];
    final token = payload['token'];
    if (user is! Map || token is! String || token.isEmpty) {
      throw const FormatException('Authentication payload is invalid');
    }

    return AuthResponse(
      user: Map<String, dynamic>.from(user),
      token: token,
      raw: json,
    );
  }
}
