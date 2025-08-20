import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../data/api/end_points.dart';
import '../../../../data/error/api_error_handler.dart';
import '../../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class PickerHelperRepo extends BaseRepo {
  PickerHelperRepo(
      {required super.dioClient, required super.sharedPreferences});

  Future<Either<ServerFailure, Response>> uploadFile(
      {required Map<String, dynamic> data,
      required Function(int, int) onReceiveProgress}) async {
    try {
      Response response = await dioClient.post(
        uri: EndPoints.uploadFileService,
        data: FormData.fromMap(data),
        onReceiveProgress: onReceiveProgress,
      );
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return left(ApiErrorHandler.getServerFailure(response.data['message']));
      }
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
