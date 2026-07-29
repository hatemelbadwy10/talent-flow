class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.userType,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String userType;

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'user_type': userType,
      };
}
