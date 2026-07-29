import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/my_projects_model.dart';
import '../model/single_project_model.dart';

abstract interface class ProjectsRepository {
  Future<Either<ServerFailure, List<MyProjectsModel>>> getProjectList({
    String? status,
    int? categoryId,
  });

  Future<Either<ServerFailure, SingleProjectModel>> getProjectDetails(int id);
}
