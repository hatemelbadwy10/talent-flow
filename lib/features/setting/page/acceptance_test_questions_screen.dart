import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/app_core.dart';
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
    final works = widget.arguments?['pendingWorks'];
    return works is List ? works.whereType<SinglePortfolioData>().toList() : [];
  }

  @override
  void initState() {
    super.initState();
    _questionsFuture = sl<AcceptanceTestRepo>().getAcceptanceTestQuestions();
  }

  Future<void> _submit(List<_AcceptanceQuestion> questions) async {
    if (questions.any(
      (question) => (_selectedAnswers[question.fieldKey] ?? '').trim().isEmpty,
    )) {
      _showMessage('acceptance_test.answer_all_questions'.tr(), false);
      return;
    }

    if (_pendingWorks.isEmpty) {
      CustomNavigator.push(Routes.navBar, clean: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await sl<AddWorkRepo>().addWorks(
      works: _pendingWorks.map((work) => work.toWorkItem()).toList(),
      answers: _selectedAnswers,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        _showMessage(failure.error, false);
      },
      (_) async {
        await UserCompletionGuard.updateStoredFlags(
          addedWorks: true,
        );
        if (!mounted) return;
        _showMessage('acceptance_test.submit_success'.tr(), true);
        CustomNavigator.push(Routes.navBar, clean: true);
      },
    );
  }

  void _showMessage(String message, bool success) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: success ? Styles.ACTIVE : Styles.IN_ACTIVE,
        isFloating: true,
      ),
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
                onTap: () => setState(() {
                  _questionsFuture =
                      sl<AcceptanceTestRepo>().getAcceptanceTestQuestions();
                }),
              );
            }

            final content = _normalizePayload(snapshot.data);
            if (content.questions.isEmpty) {
              return _StateMessage(title: 'acceptance_test.empty'.tr());
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
                        child: Text(
                          content.title.isEmpty
                              ? 'acceptance_test.title'.tr()
                              : content.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...content.questions.asMap().entries.map(
                            (entry) => _QuestionCard(
                              number: entry.key + 1,
                              question: entry.value,
                              selected: _selectedAnswers[entry.value.fieldKey],
                              onSelected: (answer) => setState(() {
                                _selectedAnswers[entry.value.fieldKey] = answer;
                              }),
                            ),
                          ),
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
                          : () => _submit(content.questions),
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _pendingWorks.isEmpty
                                  ? 'continue'.tr()
                                  : 'submit_all_works'.tr(),
                            ),
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.onSelected,
  });

  final int number;
  final _AcceptanceQuestion question;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFFFF176),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Styles.PRIMARY_COLOR,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...question.choices.map(
            (choice) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(choice),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected == choice
                          ? Styles.PRIMARY_COLOR
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected == choice
                                ? Styles.PRIMARY_COLOR
                                : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                        ),
                        child: selected == choice
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Styles.PRIMARY_COLOR,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(choice)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, this.actionLabel, this.onTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center),
          if (actionLabel != null && onTap != null)
            TextButton(onPressed: onTap, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _AcceptanceContent {
  const _AcceptanceContent({required this.title, required this.questions});

  final String title;
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

_AcceptanceContent _normalizePayload(dynamic raw) {
  final map = raw is Map ? raw : const {};
  final title = (map['title'] ?? map['name'] ?? '').toString().trim();
  final rawQuestions = map['questions'] ?? map['items'] ?? map['data'] ?? raw;
  final questions = <_AcceptanceQuestion>[];

  if (rawQuestions is List) {
    for (var index = 0; index < rawQuestions.length; index++) {
      final item = rawQuestions[index];
      if (item is! Map) continue;
      final text =
          (item['question'] ?? item['title'] ?? item['text'] ?? '').toString();
      final rawChoices =
          item['choices'] ?? item['answers'] ?? item['options'] ?? const [];
      final choices = rawChoices is List
          ? rawChoices
              .map((choice) => choice is Map
                  ? (choice['answer'] ??
                          choice['title'] ??
                          choice['text'] ??
                          choice['name'] ??
                          '')
                      .toString()
                  : choice.toString())
              .where((choice) => choice.trim().isNotEmpty)
              .toList()
          : <String>[];
      if (text.trim().isEmpty || choices.isEmpty) continue;
      questions.add(
        _AcceptanceQuestion(
          fieldKey: (item['id'] ?? item['key'] ?? index + 1).toString(),
          text: text,
          choices: choices,
        ),
      );
    }
  }
  return _AcceptanceContent(title: title, questions: questions);
}
