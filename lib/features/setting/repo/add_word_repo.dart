import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class WorkItem {
  final String title;
  final String description;
  final String date;
  final String? previewLink;
  final File? image;
  final List<File>? files;

  WorkItem({
    required this.title,
    required this.description,
    required this.date,
    this.previewLink,
    this.image,
    this.files,
  });
}

class AddWorkRepo extends BaseRepo {
  AddWorkRepo({required super.sharedPreferences, required super.dioClient});

  // ===================== Method using WorkItem list =====================
  Future<Either<ServerFailure, Response>> addWorks({
    required List<WorkItem> works,
  }) async {
    try {
      final formData = FormData();

      // Process each work item (up to 3 works)
      for (int i = 0; i < works.length && i < 3; i++) {
        final work = works[i];
        final workIndex = i + 1;

        // Add basic fields
        formData.fields.add(MapEntry('work${workIndex}_title', work.title));
        formData.fields.add(MapEntry('work${workIndex}_description', work.description));
        formData.fields.add(MapEntry('work${workIndex}_date', work.date));

        if (work.previewLink != null && work.previewLink!.isNotEmpty) {
          formData.fields.add(MapEntry('work${workIndex}_preview_link', work.previewLink!));
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

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.addWorks,
      );

      return Right(response);
    } catch (error) {
      log('AddWorkRepo error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }

  // ===================== Alternative method with separate params =====================
  Future<Either<ServerFailure, Response>> addWorksWithParams({
    required String work1Title,
    required String work1Description,
    required String work1Date,
    String? work1PreviewLink,
    File? work1Image,
    List<File>? work1Files,

    String? work2Title,
    String? work2Description,
    String? work2Date,
    String? work2PreviewLink,
    File? work2Image,
    List<File>? work2Files,

    String? work3Title,
    String? work3Description,
    String? work3Date,
    String? work3PreviewLink,
    File? work3Image,
    List<File>? work3Files,
  }) async {
    try {
      final formData = FormData();

      // Work 1
      formData.fields.add(MapEntry('work1_title', work1Title));
      formData.fields.add(MapEntry('work1_description', work1Description));
      formData.fields.add(MapEntry('work1_date', work1Date));

      if (work1PreviewLink != null) formData.fields.add(MapEntry('work1_preview_link', work1PreviewLink));
      if (work1Image != null) formData.files.add(MapEntry('work1_image', await MultipartFile.fromFile(work1Image.path)));
      if (work1Files != null && work1Files.isNotEmpty) {
        for (int i = 0; i < work1Files.length; i++) {
          formData.files.add(MapEntry('work1_files[$i]', await MultipartFile.fromFile(work1Files[i].path)));
        }
      }

      // Work 2
      if (work2Title != null && work2Description != null && work2Date != null) {
        formData.fields.add(MapEntry('work2_title', work2Title));
        formData.fields.add(MapEntry('work2_description', work2Description));
        formData.fields.add(MapEntry('work2_date', work2Date));

        if (work2PreviewLink != null) formData.fields.add(MapEntry('work2_preview_link', work2PreviewLink));
        if (work2Image != null) formData.files.add(MapEntry('work2_image', await MultipartFile.fromFile(work2Image.path)));
        if (work2Files != null && work2Files.isNotEmpty) {
          for (int i = 0; i < work2Files.length; i++) {
            formData.files.add(MapEntry('work2_files[$i]', await MultipartFile.fromFile(work2Files[i].path)));
          }
        }
      }

      // Work 3
      if (work3Title != null && work3Description != null && work3Date != null) {
        formData.fields.add(MapEntry('work3_title', work3Title));
        formData.fields.add(MapEntry('work3_description', work3Description));
        formData.fields.add(MapEntry('work3_date', work3Date));

        if (work3PreviewLink != null) formData.fields.add(MapEntry('work3_preview_link', work3PreviewLink));
        if (work3Image != null) formData.files.add(MapEntry('work3_image', await MultipartFile.fromFile(work3Image.path)));
        if (work3Files != null && work3Files.isNotEmpty) {
          for (int i = 0; i < work3Files.length; i++) {
            formData.files.add(MapEntry('work3_files[$i]', await MultipartFile.fromFile(work3Files[i].path)));
          }
        }
      }

      final response = await dioClient.post(
        data: formData,
        uri: EndPoints.addWorks,
      );

      return Right(response);
    } catch (error) {
      log('AddWorkRepo error: $error');
      return Left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
