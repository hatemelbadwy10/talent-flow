import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/home/model/entrepreneur_profile_model.dart';
import 'package:talent_flow/features/home/model/freelancer_profile_model.dart';
import 'package:talent_flow/features/home/model/freelancers_model.dart';
import 'package:talent_flow/features/home/model/home_model.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';
import 'package:talent_flow/features/payment/model/model.dart';
import 'package:talent_flow/features/setting/model/notification_model.dart';

void main() {
  test('home and payment models serialize nested values', () {
    final home = HomeModel.fromJson({
      'cards': [
        {'id': 1, 'title': 'Welcome', 'image': 'card.png'},
      ],
      'top': {
        'type': 'projects',
        'items': [
          {'id': 1, 'name': 'Top project'},
        ],
      },
      'categories': [
        {'id': 2, 'name': 'Design', 'description': 'UI', 'icon': 'ui.svg'},
      ],
      'partners': const [],
    });
    final payment = PaymentModel.fromJson({
      'id': 3,
      'name': 'Bank',
      'items': [
        {'id': 4, 'name': 'Transfer'},
      ],
    });

    expect((home.toJson()['cards'] as List).single['title'], 'Welcome');
    expect(
      ((home.toJson()['top'] as Map)['items'] as List).single['name'],
      'Top project',
    );
    expect((payment.toJson()['items'] as List).single['id'], 4);
  });

  test('profile models preserve typed verification and nested data', () {
    final freelancer = FreelancersModel.fromJson({
      'id': '7',
      'google_id': 123,
      'phone_verified_at': '2026-07-30T00:00:00Z',
      'rating': '4.5',
    });
    final profile = FreelancerProfileModel.fromJson({
      'id': 7,
      'country': 12,
      'statistics': {
        'rating': 4,
        'identity_authenticated': 1,
        'bank_account_added': true,
      },
      'reviews': const [],
      'works': const [],
    });
    final entrepreneur = EntrepreneurProfileModel.fromJson({
      'id': 8,
      'statistics': {'rating': 5, 'completed_projects': 2},
      'reviews': const [],
      'projects': [
        {'status': 'completed', 'count': 2},
      ],
    });

    expect(freelancer.toJson()['google_id'], '123');
    expect(
      freelancer.toJson()['phone_verified_at'],
      '2026-07-30T00:00:00.000Z',
    );
    expect(profile.toJson()['country'], '12');
    expect((entrepreneur.toJson()['projects'] as List).single['count'], 2);
  });

  test('notification and selection models serialize API field names', () {
    final notification = NotificationModel.fromJson({
      'id': 9,
      'date': '2026-07-30T00:00:00Z',
      'data': {'id': 10, 'freelancer_id': '11'},
      'read_status': 1,
    });
    final selection = SelectionModel.fromJson({
      'specializations': {'1': 'Design'},
      'job_titles': {'2': 'Designer'},
      'skills': {'3': 'Figma'},
    });

    expect(
      (notification.toJson()['data'] as Map)['freelancer_id'],
      11,
    );
    expect((selection.toJson()['skills'] as Map)['3'], 'Figma');
  });
}
