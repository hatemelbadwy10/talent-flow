import '../../../data/api/end_points.dart';
import '../../../main_repos/base_repo.dart';

class AcceptanceTestRepo extends BaseRepo {
  AcceptanceTestRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  Future<dynamic> getAcceptanceTestQuestions() async {
    final response =
        await dioClient.get(uri: EndPoints.acceptanceTestQuestions);
    final data = response.data;
    if (data is Map) {
      return data['payload'] ?? data;
    }
    return data;
  }
}
