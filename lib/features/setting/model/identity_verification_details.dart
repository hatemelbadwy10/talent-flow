class IdentityVerificationDetails {
  IdentityVerificationDetails({
    required this.id,
    required this.userId,
    required this.countryId,
    required this.country,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.dateOfBirth,
    required this.idCardFrontFace,
    required this.idCardBackFace,
    required this.selfieWithIdCard,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? countryId;
  final String country;
  final String firstNameAr;
  final String lastNameAr;
  final String firstNameEn;
  final String lastNameEn;
  final String dateOfBirth;
  final String idCardFrontFace;
  final String idCardBackFace;
  final String selfieWithIdCard;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory IdentityVerificationDetails.fromJson(Map<String, dynamic> json) {
    return IdentityVerificationDetails(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      countryId: _asInt(json['country_id']),
      country: json['country']?.toString() ?? '',
      firstNameAr: json['first_name_ar']?.toString() ?? '',
      lastNameAr: json['last_name_ar']?.toString() ?? '',
      firstNameEn: json['first_name_en']?.toString() ?? '',
      lastNameEn: json['last_name_en']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      idCardFrontFace: json['id_card_front_face']?.toString() ?? '',
      idCardBackFace: json['id_card_back_face']?.toString() ?? '',
      selfieWithIdCard: json['selfie_with_id_card']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
