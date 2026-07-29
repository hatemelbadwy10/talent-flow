import 'package:dartz/dartz.dart';

import '../data/error/failures.dart';
import '../main_models/user_model.dart';

abstract interface class UserRepository {
  bool get isLogIn;

  Future<Either<ServerFailure, UserModel>> fetchUserProfile();

  Either<ServerFailure, UserModel> getUser();

  Future<void> setUserData(Map<String, dynamic> json);

  UserModel? updateUnreadCounts({
    int? notifications,
    int? messages,
  });

  Future<void> clearUserData();
}
