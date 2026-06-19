// widgets/budget_field.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/app_currency.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/custom_text_form_field.dart';
import '../../../../app/core/styles.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import 'helper_text_widget.dart';

class BudgetField extends StatelessWidget {
  static const options = [
    '25 - 50',
    '50 - 100',
    '100 - 250',
    '250 - 500',
    '500 - 1000',
    '1000 - 2500',
    '2500 - 5000',
    '5000+',
  ];

  const BudgetField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: '${'add_project.budget'.tr()} (${AppCurrency.code})',
          isRequired: true,
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddProjectBloc, AddProjectState>(
          buildWhen: (previous, current) => previous.budget != current.budget,
          builder: (context, state) {
            return DropdownButtonFormField<String>(
              key: ValueKey(state.budget),
              initialValue: state.budget,
              isExpanded: true,
              menuMaxHeight: MediaQuery.sizeOf(context).height * 0.45,
              dropdownColor: Styles.FILL_COLOR,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Styles.ACCENT_COLOR,
              ),
              decoration: InputDecoration(
                hintText: 'add_project.select_budget'.tr(),
                hintStyle: const TextStyle(color: Styles.DISABLED),
                filled: true,
                fillColor: Styles.FILL_COLOR,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                border: _budgetBorder(Styles.LIGHT_BORDER_COLOR),
                enabledBorder: _budgetBorder(Styles.LIGHT_BORDER_COLOR),
                focusedBorder: _budgetBorder(Styles.ACCENT_COLOR),
                errorBorder: _budgetBorder(Styles.FAILED_COLOR),
                focusedErrorBorder: _budgetBorder(Styles.FAILED_COLOR),
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: const TextStyle(color: Styles.PRIMARY_COLOR),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                context.read<AddProjectBloc>().add(UpdateBudget(budget: value));
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'add_project.budget_validation'.tr();
                }
                return null;
              },
            );
          },
        ),
        HelperText(text: 'add_project.budget_helper'.tr()),
      ],
    );
  }
}

OutlineInputBorder _budgetBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

// widgets/duration_field.dart
class DurationField extends StatelessWidget {
  final TextEditingController controller;

  const DurationField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.duration'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hint: 'add_project.duration_hint'.tr(),
          inputType: TextInputType.number,
          formattedType: [FilteringTextInputFormatter.digitsOnly],
          sufWidget: Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Text(
              'add_project.duration_suffix'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Styles.HINT_COLOR,
              ),
            ),
          ),
          onChanged: (value) {
            context.read<AddProjectBloc>().add(
                  UpdateDuration(duration: int.tryParse(value) ?? 0),
                );
          },
          validate: (value) {
            if (value == null || value.isEmpty) {
              return 'add_project.field_required'.tr();
            }
            if (int.tryParse(value) == null) {
              return 'add_project.invalid_duration'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}
