import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/new_projects/widgets/budget_duration.dart';

void main() {
  test('create project budget dropdown contains all supported ranges', () {
    expect(
      BudgetField.options,
      [
        '25 - 50',
        '50 - 100',
        '100 - 250',
        '250 - 500',
        '500 - 1000',
        '1000 - 2500',
        '2500 - 5000',
        '5000+',
      ],
    );
  });
}
