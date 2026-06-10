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
import '../../projects/model/single_project_model.dart';
import '../bloc/new_projects_bloc.dart';

class AddOfferWidget extends StatefulWidget {
  final int id;
  final int? proposalId;
  final String? initialDescription;
  final List<ProjectQuestionDetail> questions;
  final Map<int, String> initialQuestionAnswers;

  const AddOfferWidget({
    super.key,
    required this.id,
    this.proposalId,
    this.initialDescription,
    this.questions = const [],
    this.initialQuestionAnswers = const {},
  });

  @override
  State<AddOfferWidget> createState() => _AddOfferWidgetState();
}

class _AddOfferWidgetState extends State<AddOfferWidget> {
  final TextEditingController _controller = TextEditingController();
  final Map<int, TextEditingController> _answerControllers = {};
  bool _isLoading = false;

  bool get _isEditing => widget.proposalId != null;
  bool get _requiredQuestionsAnswered => widget.questions
      .where((question) => question.isRequired)
      .every((question) =>
          question.id != null &&
          (_answerControllers[question.id]?.text.trim().isNotEmpty ?? false));

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDescription?.trim() ?? '';
    for (final question in widget.questions) {
      if (question.id == null) continue;
      _answerControllers[question.id!] = TextEditingController(
        text: widget.initialQuestionAnswers[question.id!]?.trim() ?? '',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

    context.read<NewProjectsBloc>().add(
          Click(arguments: {
            "projectId": widget.id,
            "description": description,
            "proposalId": widget.proposalId,
            "questionAnswers": {
              for (final entry in _answerControllers.entries)
                if (entry.value.text.trim().isNotEmpty)
                  entry.key: entry.value.text.trim(),
            },
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
              _isEditing
                  ? 'add_offer.update_title'.tr()
                  : 'add_offer.title'.tr(),
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
            if (widget.questions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              const Divider(height: 1, thickness: .5),
              SizedBox(height: 16.h),
              Text(
                'add_offer.questions_title'.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8.h),
              ...widget.questions.map((question) {
                final questionId = question.id;
                if (questionId == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: CustomTextField(
                    controller: _answerControllers[questionId],
                    label: question.question ?? '-',
                    hint: 'add_offer.answer_hint'.tr(),
                    minLines: 2,
                    maxLines: 4,
                    validate: question.isRequired
                        ? (value) => value == null || value.trim().isEmpty
                            ? 'field_required'.tr()
                            : null
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                );
              }),
            ],
            SizedBox(height: 16.h),
            CustomButton(
                text: _isLoading
                    ? 'loading'.tr()
                    : (_isEditing
                        ? 'add_offer.update_button'.tr()
                        : 'submit_button'.tr()),
                isActive: !_isLoading && _requiredQuestionsAnswered,
                onTap: _isLoading || !_requiredQuestionsAnswered
                    ? null
                    : _submitOffer,
                isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
