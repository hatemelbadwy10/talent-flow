import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../components/custom_button.dart';
import '../bloc/new_projects_bloc.dart';
import '../../projects/model/single_project_model.dart';

class AddOfferWidget extends StatefulWidget {
  final int id;
  final int? proposalId;
  final String? initialDescription;
  final List<ProjectQuestion> questions;

  const AddOfferWidget({
    super.key,
    required this.id,
    this.proposalId,
    this.initialDescription,
    this.questions = const [],
  });

  @override
  State<AddOfferWidget> createState() => _AddOfferWidgetState();
}

class _AddOfferWidgetState extends State<AddOfferWidget> {
  final TextEditingController _controller = TextEditingController();
  final Map<int, TextEditingController> _questionControllers =
      <int, TextEditingController>{};
  bool _isLoading = false;

  bool get _isEditing => widget.proposalId != null;
  bool get _hasQuestions => widget.questions.isNotEmpty;
  bool get _hasUnansweredRequiredQuestions {
    for (final question in widget.questions) {
      if (!question.isRequired) {
        continue;
      }
      final id = question.id;
      if (id == null) {
        continue;
      }
      final answer = _questionControllers[id]?.text.trim() ?? '';
      if (answer.isEmpty) {
        return true;
      }
    }
    return false;
  }

  bool get _canSubmit => !_isLoading && !_hasUnansweredRequiredQuestions;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDescription?.trim() ?? '';
    for (final question in widget.questions) {
      final id = question.id;
      if (id == null) {
        continue;
      }
      _questionControllers[id] = TextEditingController()
        ..addListener(_onQuestionAnswerChanged);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _questionControllers.values) {
      controller
        ..removeListener(_onQuestionAnswerChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onQuestionAnswerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showErrorSnackBar(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.IN_ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  void _submitOffer() {
    final description = _controller.text.trim();
    if (description.isEmpty) {
      _showErrorSnackBar('add_offer.empty_description'.tr());
      return;
    }
    if (_hasUnansweredRequiredQuestions) {
      _showErrorSnackBar('Please answer all required questions');
      return;
    }

    final answers = widget.questions
        .where((question) => question.id != null)
        .map((question) {
          final answer =
              _questionControllers[question.id!]!.text.trim();
          return {
            'question_id': question.id,
            'answer': answer,
          };
        })
        .where((answer) => (answer['answer']?.toString().trim().isNotEmpty ?? false))
        .toList();

    context.read<NewProjectsBloc>().add(
          Click(arguments: {
            "projectId": widget.id,
            "description": description,
            "proposalId": widget.proposalId,
            "answers": answers,
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewProjectsBloc, AppState>(
      listener: (context, state) {
        if (state is Loading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is Done) {
          final successMessage =
              state.data?.toString().trim().isNotEmpty == true
                  ? state.data.toString()
                  : (_isEditing
                      ? 'add_offer.update_success'.tr()
                      : 'add_offer.success'.tr());
          setState(() {
            _isLoading = false;
          });
          _showSuccessSnackBar(successMessage);

          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            CustomNavigator.pop(result: true);
          });
        } else if (state is Error) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(
            _isEditing ? 'add_offer.update_error'.tr() : 'add_offer.error'.tr(),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'add_offer.update_title'.tr() : 'add_offer.title'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1, thickness: .5),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _controller,
              maxLines: 5,
              minLines: 3,
              hint: 'add_offer.hint'.tr(),
            ),
            if (_hasQuestions) ...[
              SizedBox(height: 16.h),
              const Divider(height: 1, thickness: .5),
              SizedBox(height: 16.h),
              const Text(
                'Project questions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 12.h),
              ...widget.questions.map(
                (question) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _QuestionAnswerField(
                    question: question,
                    controller: question.id == null
                        ? TextEditingController()
                        : _questionControllers[question.id!]!,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            CustomButton(
                text: _isLoading
                    ? 'loading'.tr()
                    : (_isEditing
                        ? 'add_offer.update_button'.tr()
                        : 'submit_button'.tr()),
                isActive: _canSubmit,
                onTap: _canSubmit ? _submitOffer : null,
                isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}

class _QuestionAnswerField extends StatelessWidget {
  const _QuestionAnswerField({
    required this.question,
    required this.controller,
  });

  final ProjectQuestion question;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final title = question.question?.trim().isNotEmpty == true
        ? question.question!.trim()
        : 'Question';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (question.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: controller,
          maxLines: 3,
          minLines: 2,
          hint: 'Write your answer',
        ),
      ],
    );
  }
}
