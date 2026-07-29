final class AcceptanceTestContent {
  const AcceptanceTestContent({
    required this.title,
    required this.description,
    required this.questions,
  });

  final String title;
  final String description;
  final List<AcceptanceTestQuestion> questions;

  factory AcceptanceTestContent.fromPayload(Object? raw) {
    final map = _asMap(raw);
    final questions = <AcceptanceTestQuestion>[
      ..._extractQuestions(map?['questions']),
      ..._extractQuestions(map?['items']),
      ..._extractQuestions(map?['data']),
    ];

    if (questions.isEmpty) {
      questions.addAll(_extractQuestions(raw));
    }

    return AcceptanceTestContent(
      title: _firstText([map?['title'], map?['name'], map?['header']]),
      description: _firstText([
        map?['description'],
        map?['content'],
        map?['body'],
        map?['intro'],
      ]),
      questions: List.unmodifiable(questions),
    );
  }
}

final class AcceptanceTestQuestion {
  const AcceptanceTestQuestion({
    required this.fieldKey,
    required this.text,
    required this.choices,
  });

  final String fieldKey;
  final String text;
  final List<String> choices;
}

Map<String, Object?>? _asMap(Object? value) {
  if (value is! Map) return null;
  return value.map((key, item) => MapEntry(key.toString(), item));
}

String _firstText(Iterable<Object?> candidates) {
  for (final candidate in candidates) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

List<AcceptanceTestQuestion> _extractQuestions(Object? value) {
  if (value is List) {
    return value
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          final map = _asMap(item);
          if (map != null) {
            final fieldKey = _firstText([map['id'], map['key'], map['field']]);
            final text = _firstText([
              map['question'],
              map['title'],
              map['name'],
              map['text'],
              map['content'],
            ]);
            if (text.isEmpty) return null;
            return AcceptanceTestQuestion(
              fieldKey: fieldKey.isNotEmpty ? fieldKey : '${entry.key + 1}',
              text: text,
              choices: _extractChoices(map['choices']),
            );
          }
          final text = item?.toString().trim() ?? '';
          if (text.isEmpty) return null;
          return AcceptanceTestQuestion(
            fieldKey: '${entry.key + 1}',
            text: text,
            choices: const [],
          );
        })
        .whereType<AcceptanceTestQuestion>()
        .toList(growable: false);
  }

  final map = _asMap(value);
  if (map == null) return const [];
  return map.entries
      .map((entry) {
        final text = entry.value?.toString().trim() ?? '';
        if (text.isEmpty) return null;
        return AcceptanceTestQuestion(
          fieldKey: entry.key,
          text: text,
          choices: const [],
        );
      })
      .whereType<AcceptanceTestQuestion>()
      .toList(growable: false);
}

List<String> _extractChoices(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
