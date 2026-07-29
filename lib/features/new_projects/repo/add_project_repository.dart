import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/project_question.dart';

abstract interface class AddProjectRepository {
  Future<Either<ServerFailure, String>> addProject({
    required int specializationId,
    required String title,
    required String description,
    required List<int> skills,
    required String budget,
    required int duration,
    List<File>? files,
    String? filesDescription,
    List<String>? similarProjects,
    String? requiredToBeReceived,
    List<ProjectQuestion>? questions,
  });
}
