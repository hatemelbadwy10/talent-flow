import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/home_model.dart';

abstract interface class CategoriesRepository {
  Future<Either<ServerFailure, List<Category>>> getCategoryList();
}
