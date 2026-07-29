import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import 'package:dartz/dartz.dart';
import 'about_repository.dart';

class AboutRepo extends BaseRepo implements AboutRepository {
  AboutRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  @override
  Future<Either<ServerFailure, String>> getAboutContent() async {
    try {
      final response = await dioClient.get(uri: EndPoints.aboutUs);

      final data = Map<String, dynamic>.from(response.data as Map);
      final payload = Map<String, dynamic>.from(data['payload'] as Map);
      return right(payload['content']?.toString() ?? '');
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
