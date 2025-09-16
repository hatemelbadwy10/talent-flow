import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/helper_text_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';

import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import '../repo/add_project_repo.dart';
import 'add_question_dialog.dart';

class QuestionSection extends StatelessWidget {
  const QuestionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProjectBloc, AddProjectState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(text: 'add_project.project_questions'.tr()),
            const SizedBox(height: 8),

            // عرض الأسئلة الموجودة
            ...state.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionItem(context, index, question);
            }),

            // زر إضافة سؤال جديد
            OutlinedButton(
              onPressed: () => _showAddQuestionDialog(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20,color: Styles.PRIMARY_COLOR,),
                  const SizedBox(width: 8),
                  Text(
                    'add_project.add_question'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold,color: Styles.PRIMARY_COLOR),
                  ),
                ],
              ),
            ),

            HelperText(text: 'add_project.questions_helper'.tr()),
          ],
        );
      },
    );
  }

  Widget _buildQuestionItem(BuildContext context, int index, ProjectQuestion question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: question.isRequired,
                      onChanged: (bool? value) {
                        final updatedQuestion = ProjectQuestion(
                          question: question.question,
                          isRequired: value ?? false,
                        );
                        context.read<AddProjectBloc>().add(
                          UpdateQuestion(index: index, question: updatedQuestion),
                        );
                      },
                    ),
                    Text('add_project.mandatory_question'.tr()),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<AddProjectBloc>().add(RemoveQuestion(index: index));
                  },
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text(
                    'add_project.delete'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AddQuestionDialog(
          onAdd: (questionText, isRequired) {
            final question = ProjectQuestion(
              question: questionText,
              isRequired: isRequired,
            );
            // استخدام Service Locator مباشرة
            log("question ${question}");
            context.read<AddProjectBloc>().add(AddQuestion(question: question));
          },
        );
      },
    );
  }
}
