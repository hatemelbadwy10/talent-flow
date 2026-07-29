import '../../../main_models/user_model.dart';

class ProfileUpdateResult {
  const ProfileUpdateResult({
    required this.message,
    this.user,
  });

  final String message;
  final UserModel? user;
}
