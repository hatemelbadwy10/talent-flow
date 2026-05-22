import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/portofilo_form_bloc.dart';
import 'package:talent_flow/features/setting/repo/acceptance_test_repo.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../../../app/core/app_core.dart';

class AcceptanceTestQuestionsScreen extends StatefulWidget {
  const AcceptanceTestQuestionsScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<AcceptanceTestQuestionsScreen> createState() =>
      _AcceptanceTestQuestionsScreenState();
}

class _AcceptanceTestQuestionsScreenState
    extends State<AcceptanceTestQuestionsScreen> {
  late Future<dynamic> _questionsFuture;
  final Map<String, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  List<SinglePortfolioData> get _pendingWorks {
    final rawWorks = widget.arguments?['pendingWorks'];
    if (rawWorks is List<SinglePortfolioData>) {
      return rawWorks;
    }
    if (rawWorks is List) {
      return rawWorks.whereType<SinglePortfolioData>().toList();
    }
    return const <SinglePortfolioData>[];
  }

  @override
  void initState() {
    super.initState();
    _questionsFuture = sl<AcceptanceTestRepo>().getAcceptanceTestQuestions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitAnswers(List<_AcceptanceQuestion> questions) async {
    final answers = <String, String>{};
    for (final question in questions) {
      final value = _selectedAnswers[question.fieldKey]?.trim() ?? '';
      if (value.isEmpty) {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: 'acceptance_test.answer_all_questions'.tr(),
            backgroundColor: Styles.IN_ACTIVE,
            isFloating: true,
          ),
        );
        return;
      }
      answers[question.fieldKey] = value;
    }

    if (_pendingWorks.isEmpty) {
      CustomNavigator.push(Routes.navBar, clean: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await sl<AddWorkRepo>().addWorks(
      works: _pendingWorks.map((item) => item.toWorkItem()).toList(),
      answers: answers,
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
        });
        AppCore.showSnackBar(
          notification: AppNotification(
            message: failure.error,
            backgroundColor: Styles.IN_ACTIVE,
            isFloating: true,
          ),
        );
      },
      (_) async {
        await UserCompletionGuard.updateStoredFlags(addedWorks: true);
        if (!mounted) {
          return;
        }
        setState(() {
          _isSubmitting = false;
        });
        AppCore.showSnackBar(
          notification: AppNotification(
            message: 'user_completion.work_completed'.tr(),
            backgroundColor: Styles.ACTIVE,
            isFloating: true,
          ),
        );
        CustomNavigator.push(Routes.navBar, clean: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: CustomAppBar(
        title: 'acceptance_test.title'.tr(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _StateMessage(
                title: 'acceptance_test.load_failed'.tr(),
                actionLabel: 'retry'.tr(),
                onTap: () {
                  setState(() {
                    _questionsFuture =
                        sl<AcceptanceTestRepo>().getAcceptanceTestQuestions();
                  });
                },
              );
            }

            final content = _normalizeAcceptancePayload(snapshot.data);
            final resolvedTitle = _resolveAcceptanceTitle(
              context,
              content.title,
            );
            if (content.questions.isEmpty &&
                content.title.isEmpty &&
                content.description.isEmpty) {
              return  _StateMessage(
                title: 'acceptance_test.empty'.tr(),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resolvedTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            if (content.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                content.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (content.questions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...content.questions.asMap().entries.map(
                              (entry) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            color: Styles.SMOKED_WHITE_COLOR,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(
                                              color: Styles.PRIMARY_COLOR,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value.text,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (entry.value.choices.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      ...entry.value.choices.map(
                                        (choice) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: _ChoiceTile(
                                            label: choice,
                                            selected:
                                                _selectedAnswers[entry
                                                        .value.fieldKey] ==
                                                    choice,
                                            onTap: () {
                                              setState(() {
                                                _selectedAnswers[entry
                                                    .value.fieldKey] = choice;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitAnswers(content.questions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_pendingWorks.isEmpty
                              ? 'continue'.tr()
                              : 'submit_all_works'.tr()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AcceptanceContent {
  const _AcceptanceContent({
    required this.title,
    required this.description,
    required this.questions,
  });

  final String title;
  final String description;
  final List<_AcceptanceQuestion> questions;
}

class _AcceptanceQuestion {
  const _AcceptanceQuestion({
    required this.fieldKey,
    required this.text,
    required this.choices,
  });

  final String fieldKey;
  final String text;
  final List<String> choices;
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Styles.PRIMARY_COLOR.withValues(alpha: 0.08)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Styles.PRIMARY_COLOR : const Color(0xFFE5E7EB),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                      selected ? Styles.PRIMARY_COLOR : const Color(0xFF111827),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected ? Styles.PRIMARY_COLOR : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: selected ? Styles.PRIMARY_COLOR : Colors.transparent,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onTap != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onTap,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

_AcceptanceContent _normalizeAcceptancePayload(dynamic raw) {
  final map = _asMap(raw);
  final title = _firstText([
    map?['title'],
    map?['name'],
    map?['header'],
  ]);
  final description = _firstText([
    map?['description'],
    map?['content'],
    map?['body'],
    map?['intro'],
  ]);

  final questions = <_AcceptanceQuestion>[
    ..._extractQuestions(map?['questions']),
    ..._extractQuestions(map?['items']),
    ..._extractQuestions(map?['data']),
  ];

  if (questions.isEmpty) {
    questions.addAll(_extractQuestions(raw));
  }

  return _AcceptanceContent(
    title: title,
    description: description,
    questions: questions,
  );
}

String _resolveAcceptanceTitle(BuildContext context, String rawTitle) {
  final normalized = rawTitle.trim().toLowerCase();
  if (normalized.isEmpty ||
      normalized == 'acceptance test' ||
      normalized == 'acceptance_test' ||
      normalized == 'acceptance-test' ||
      normalized == 'اختبار القبول') {
    return 'acceptance_test.title'.tr();
  }

  return rawTitle;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

String _firstText(List<dynamic> candidates) {
  for (final candidate in candidates) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }
  return '';
}

List<_AcceptanceQuestion> _extractQuestions(dynamic value) {
  if (value is List) {
    return value.asMap().entries.map((entry) {
      final item = entry.value;
      if (item is Map) {
        final fieldKey = _firstText([
          item['id'],
          item['key'],
          item['field'],
        ]);
        final text = _firstText([
          item['question'],
          item['title'],
          item['name'],
          item['text'],
          item['content'],
        ]);
        if (text.isEmpty) {
          return null;
        }
      return _AcceptanceQuestion(
        fieldKey: fieldKey.isNotEmpty ? fieldKey : '${entry.key + 1}',
        text: text,
        choices: _extractChoices(item['choices']),
      );
      }
      final text = item?.toString().trim() ?? '';
      if (text.isEmpty) {
        return null;
      }
      return _AcceptanceQuestion(
        fieldKey: '${entry.key + 1}',
        text: text,
        choices: const <String>[],
      );
    }).whereType<_AcceptanceQuestion>().toList();
  }

  if (value is Map) {
    return value.entries.map((entry) {
      final text = entry.value?.toString().trim() ?? '';
      if (text.isEmpty) {
        return null;
      }
      return _AcceptanceQuestion(
        fieldKey: entry.key.toString(),
        text: text,
        choices: const <String>[],
      );
    }).whereType<_AcceptanceQuestion>().toList();
  }

  return const <_AcceptanceQuestion>[];
}

List<String> _extractChoices(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
}
