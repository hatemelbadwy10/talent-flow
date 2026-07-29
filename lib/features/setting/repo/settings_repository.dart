import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/help_model.dart';

abstract interface class SettingsRepository {
  Future<Either<ServerFailure, String>> help(HelpModel model);
  Future<Either<ServerFailure, String>> logout();
  Future<Either<ServerFailure, String>> deleteAccount();
}
