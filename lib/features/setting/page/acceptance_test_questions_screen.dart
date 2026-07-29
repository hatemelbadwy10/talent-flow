import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/features/setting/bloc/portofilo_form_bloc.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/setting/model/acceptance_test_content.dart';
import 'package:talent_flow/features/setting/repo/acceptance_test_repository.dart';
import 'package:talent_flow/features/setting/repo/add_work_repository.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../../../app/core/app_core.dart';
import '../model/user_completion_route_args.dart';

class AcceptanceTestQuestionsScreen extends StatefulWidget {
  const AcceptanceTestQuestionsScreen({
    super.key,
    required this.arguments,
    required this.acceptanceTestRepository,
    required this.workRepository,
  });

  final AcceptanceTestRouteArgs arguments;
  final AcceptanceTestRepository acceptanceTestRepository;
  final AddWorkRepository workRepository;

  @override
  State<AcceptanceTestQuestionsScreen> createState() =>
      _AcceptanceTestQuestionsScreenState();
}

class _AcceptanceTestQuestionsScreenState
    extends State<AcceptanceTestQuestionsScreen> {
  late Future<Either<ServerFailure, AcceptanceTestContent>> _questionsFuture;
  final Map<String, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  List<SinglePortfolioData> get _pendingWorks => widget.arguments.pendingWorks;

  @override
  void initState() {
    super.initState();
    _questionsFuture =
        widget.acceptanceTestRepository.getAcceptanceTestQuestions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitAnswers(List<AcceptanceTestQuestion> questions) async {
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

    final result = await widget.workRepository.addWorks(
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
        child: FutureBuilder<Either<ServerFailure, AcceptanceTestContent>>(
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
                    _questionsFuture = widget.acceptanceTestRepository
                        .getAcceptanceTestQuestions();
                  });
                },
              );
            }

            final result = snapshot.data;
            if (result == null) {
              return _StateMessage(
                title: 'acceptance_test.load_failed'.tr(),
              );
            }
            return result.fold(
              (failure) => _StateMessage(
                title: failure.error,
                actionLabel: 'retry'.tr(),
                onTap: () {
                  setState(() {
                    _questionsFuture = widget.acceptanceTestRepository
                        .getAcceptanceTestQuestions();
                  });
                },
              ),
              (content) {
                final resolvedTitle = _resolveAcceptanceTitle(
                  context,
                  content.title,
                );
                if (content.questions.isEmpty &&
                    content.title.isEmpty &&
                    content.description.isEmpty) {
                  return _StateMessage(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color:
                                                    Styles.SMOKED_WHITE_COLOR,
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
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: _ChoiceTile(
                                                label: choice,
                                                selected: _selectedAnswers[
                                                        entry.value.fieldKey] ==
                                                    choice,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedAnswers[entry.value
                                                        .fieldKey] = choice;
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
            );
          },
        ),
      ),
    );
  }
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
