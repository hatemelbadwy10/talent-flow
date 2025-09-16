import '../../../data/api/end_points.dart';
import '../../../main_repos/base_repo.dart';

class AboutRepo extends BaseRepo {
  AboutRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  Future<String> getAboutContent() async {
    try {
      final response = await dioClient.get(uri: EndPoints.aboutUs);

      return response.data['payload']['content'] as String;
    } catch (error) {
      return '';
    }
  }
}
