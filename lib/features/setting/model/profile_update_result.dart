class ProfileUpdateResult {
  const ProfileUpdateResult({
    required this.message,
    this.user,
  });

  final String message;
  final Map<String, dynamic>? user;
}
