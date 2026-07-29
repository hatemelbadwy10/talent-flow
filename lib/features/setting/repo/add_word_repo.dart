import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/edit_work_request_model.dart';
import '../model/work_item.dart';
import 'add_work_repository.dart';
import 'edit_work_repository.dart';

class AddWorkRepo extends BaseRepo
    implements AddWorkRepository, EditWorkRepository {
  AddWorkRepo({required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, String>> addWork({
    required WorkItem work,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('title', work.title));
      formData.fields.add(MapEntry('description', work.description));
      formData.fields.add(MapEntry('date', work.date));

      if (work.previewLink != null && work.previewLink!.isNotEmpty) {
        formData.fields.add(MapEntry('preview_link', work.previewLink!));
      }

      if (work.image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(work.image!.path),
          ),
        );
      }

      if (work.files != null && work.files!.isNotEmpty) {
        for (int fileIndex = 0; fileIndex < work.files!.length; fileIndex++) {
          formData.files.add(
            MapEntry(
              'files[$fileIndex]',
              await MultipartFile.fromFile(work.files![fileIndex].path),
            ),
          );
        }
      }

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.addWork,
      );

      return Right(_responseMessage(response.data));
    } catch (error) {
      log('AddWorkRepo addWork error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  // ===================== Method using WorkItem list =====================
  @override
  Future<Either<ServerFailure, String>> addWorks({
    required List<WorkItem> works,
    Map<String, String>? answers,
  }) async {
    try {
      final formData = FormData();

      // Process each work item (up to 3 works)
      for (int i = 0; i < works.length && i < 3; i++) {
        final work = works[i];
        final workIndex = i + 1;

        // Add basic fields
        formData.fields.add(MapEntry('work${workIndex}_title', work.title));
        formData.fields
            .add(MapEntry('work${workIndex}_description', work.description));
        formData.fields.add(MapEntry('work${workIndex}_date', work.date));

        if (work.previewLink != null && work.previewLink!.isNotEmpty) {
          formData.fields.add(
              MapEntry('work${workIndex}_preview_link', work.previewLink!));
        }

        // Add single image
        if (work.image != null) {
          formData.files.add(MapEntry(
            'work${workIndex}_image',
            await MultipartFile.fromFile(work.image!.path),
          ));
        }

        // Add multiple files
        if (work.files != null && work.files!.isNotEmpty) {
          for (int fileIndex = 0; fileIndex < work.files!.length; fileIndex++) {
            formData.files.add(MapEntry(
              'work${workIndex}_files[$fileIndex]',
              await MultipartFile.fromFile(work.files![fileIndex].path),
            ));
          }
        }
      }

      if (answers != null && answers.isNotEmpty) {
        for (final entry in answers.entries) {
          formData.fields.add(MapEntry(entry.key, entry.value));
        }
      }

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.addWorks,
      );

      return Right(_responseMessage(response.data));
    } catch (error) {
      log('AddWorkRepo error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> updateWork({
    required EditWorkRequestModel request,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('title', request.title));
      formData.fields.add(MapEntry('description', request.description));
      formData.fields.add(MapEntry('date', request.date));
      formData.fields
          .add(MapEntry('preview_link', request.previewLink?.trim() ?? ''));

      for (int index = 0; index < request.skillIds.length; index++) {
        formData.fields.add(
            MapEntry('skills[$index]', request.skillIds[index].toString()));
      }

      if (request.image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(request.image!.path),
          ),
        );
      }

      for (int index = 0; index < request.newFiles.length; index++) {
        formData.files.add(
          MapEntry(
            'files[$index]',
            await MultipartFile.fromFile(request.newFiles[index].path),
          ),
        );
      }

      for (int index = 0; index < request.oldFiles.length; index++) {
        formData.fields
            .add(MapEntry('old_files[$index]', request.oldFiles[index]));
      }

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.workEdit(request.id),
      );

      return Right(_messageFrom(response.data));
    } catch (error) {
      log('AddWorkRepo updateWork error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, String>> deleteWork(int id) async {
    try {
      final response = await dioClient.delete(uri: EndPoints.workDetails(id));
      return Right(_messageFrom(response.data));
    } catch (error) {
      log('AddWorkRepo deleteWork error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  String _messageFrom(Object? data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }
}

String _responseMessage(dynamic data) {
  return data is Map ? data['message']?.toString() ?? '' : '';
}
