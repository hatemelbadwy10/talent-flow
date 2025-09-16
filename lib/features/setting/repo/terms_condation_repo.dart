
import '../../../data/api/end_points.dart';
import '../../../main_repos/base_repo.dart';

class TermsAndConditionRepo extends BaseRepo {
  TermsAndConditionRepo({required super.sharedPreferences, required super.dioClient});

  Future<String> getTermsAndCondition() async {
    try {
      final response = await dioClient.get(uri: EndPoints.termsConditions);
      return response.data['payload']['content'] as String;
    } catch (error) {
      return '';
    }
  }
}
