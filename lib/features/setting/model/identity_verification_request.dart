import 'dart:io';

class IdentityVerificationRequest {
  IdentityVerificationRequest({
    required this.countryId,
    required this.firstNameAr,
    required this.lastNameAr,
    required this.firstNameEn,
    required this.lastNameEn,
    required this.dateOfBirth,
    required this.idCardFrontFace,
    required this.idCardBackFace,
    required this.selfieWithIdCard,
  });

  final int countryId;
  final String firstNameAr;
  final String lastNameAr;
  final String firstNameEn;
  final String lastNameEn;
  final String dateOfBirth;
  final File idCardFrontFace;
  final File idCardBackFace;
  final File selfieWithIdCard;
}
