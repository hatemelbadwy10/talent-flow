import '../../../models/auth_response.dart';

class ConfirmCodeResult {
  const ConfirmCodeResult({
    required this.message,
    this.authResponse,
  });

  final String message;
  final AuthResponse? authResponse;
}
