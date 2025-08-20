import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../data/api/end_points.dart';
import '../../../../data/error/api_error_handler.dart';
import '../../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class DeleteFileRepo extends BaseRepo {
  DeleteFileRepo({required super.dioClient, required super.sharedPreferences});

  Future<Either<ServerFailure, Response>> deleteFile(id) async {
    try {
      Response response = await dioClient.delete(
        uri: EndPoints.deleteFile(id),
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
