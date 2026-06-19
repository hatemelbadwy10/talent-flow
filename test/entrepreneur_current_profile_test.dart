import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/home/model/entrepreneur_profile_model.dart';
import 'package:talent_flow/main_models/user_model.dart';

void main() {
  const profileJson = <String, dynamic>{
    'id': 104,
    'image': 'https://talentflowa.com/profile.jpg',
    'user_type': 'Entrepreneur',
    'first_name': 'maha',
    'last_name': 'Ali',
    'country': 'اليمن',
    'job_title': 'مهندس معمار',
    'statistics': {
      'rating': 4,
      'completed_projects': 10,
      'in_progress_projects': 5,
      'city': 'عدن',
    },
    'reviews': [
      {
        'id': 11,
        'name': 'Ali Adel',
        'rating': 4,
        'comment': 'test',
      },
    ],
  };

  test('UserModel preserves entrepreneur profile details', () {
    final userJson = UserModel.fromJson(profileJson).toJson();

    expect(userJson['country'], 'اليمن');
    expect((userJson['reviews'] as List), hasLength(1));
    expect(
      (userJson['statistics'] as Map<String, dynamic>)['completed_projects'],
      10,
    );
  });

  test('entrepreneur profile reads reviews and project statistics', () {
    final model = EntrepreneurProfileModel.fromJson(
        UserModel.fromJson(profileJson).toJson());

    expect(model.name, 'maha Ali');
    expect(model.reviews, hasLength(1));
    expect(model.averageRating, 4);
    expect(model.statistics?.completedProjects, 10);
    expect(model.statistics?.inProgressProjects, 5);
    expect(model.totalProjects, 15);
  });
}
