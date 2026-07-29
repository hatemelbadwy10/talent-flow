import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/selection_option_model.dart';

abstract interface class SelectionOptionsRepository {
  Future<Either<ServerFailure, SelectionModel>> getSelectionOptions();
}
