import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/setting/model/acceptance_test_content.dart';

void main() {
  group('AcceptanceTestContent', () {
    test('parses the production question payload into typed fields', () {
      final content = AcceptanceTestContent.fromPayload({
        'title': 'Acceptance test',
        'description': 'Choose one answer',
        'questions': [
          {
            'id': 7,
            'question': 'What is your specialty?',
            'choices': ['Design', 'Development'],
          },
        ],
      });

      expect(content.title, 'Acceptance test');
      expect(content.description, 'Choose one answer');
      expect(content.questions, hasLength(1));
      expect(content.questions.single.fieldKey, '7');
      expect(content.questions.single.text, 'What is your specialty?');
      expect(
        content.questions.single.choices,
        ['Design', 'Development'],
      );
    });

    test('supports legacy keyed questions', () {
      final content = AcceptanceTestContent.fromPayload({
        'questions': {
          'experience': 'How many years of experience?',
        },
      });

      expect(content.questions.single.fieldKey, 'experience');
      expect(
        content.questions.single.text,
        'How many years of experience?',
      );
    });

    test('returns an empty immutable result for malformed payloads', () {
      final content = AcceptanceTestContent.fromPayload(null);

      expect(content.title, isEmpty);
      expect(content.description, isEmpty);
      expect(content.questions, isEmpty);
      expect(
        () => content.questions.add(
          const AcceptanceTestQuestion(
            fieldKey: '1',
            text: 'Question',
            choices: [],
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
