import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/home/model/freelancers_model.dart';

void main() {
  test('parses decimal freelancer rating without type error', () {
    final freelancer = FreelancersModel.fromJson({
      'id': 102,
      'name': 'عبدالله باعوم',
      'rating': 4.7,
      'no_of_reviews': 7,
      'logged_in': false,
    });

    expect(freelancer.id, 102);
    expect(freelancer.rating, 4.7);
    expect(freelancer.noOfReviews, 7);
    expect(freelancer.loggedIn, isFalse);
  });

  test('parses numeric freelancer fields returned as strings', () {
    final freelancer = FreelancersModel.fromJson({
      'id': '105',
      'rating': '5',
      'no_of_reviews': '1',
      'logged_in': '1',
      'is_in_favorites': '1',
    });

    expect(freelancer.id, 105);
    expect(freelancer.rating, 5.0);
    expect(freelancer.noOfReviews, 1);
    expect(freelancer.loggedIn, isTrue);
    expect(freelancer.isInFavorites, isTrue);
  });
}
