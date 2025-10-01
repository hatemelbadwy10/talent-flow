class HelpModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String message;

  HelpModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "message": message,
    };
  }
}
