// widgets/specialization_dropdown.dart
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import '../../../../components/dynamic_drop_down_button.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';

class DropdownItem {
  final String tag;
  final dynamic value;
  DropdownItem(this.tag, {this.value});
}

class SpecializationDropdown extends StatelessWidget {
  final Map<String, String> specializations;

  const SpecializationDropdown({
    super.key,
    required this.specializations,
  });

  @override
  Widget build(BuildContext context) {
    final items = specializations.entries
        .map((entry) => DropdownItem(entry.value, value: int.parse(entry.key)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.specialization'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddProjectBloc, AddProjectState>(
          buildWhen: (previous, current) =>
          previous.specializationId != current.specializationId,
          builder: (context, state) {
            return DynamicDropDownButton(
              items: items,
              name: state.specializationName??'add_project.select_specialization'.tr(),
              selectedValue: state.specializationId,
              
              onChange: (selectedItem) {
                if (selectedItem != null) {
                  log("selected item ${selectedItem.value}");
                  context.read<AddProjectBloc>().add(
                    UpdateSpecializationId(
                      specializationName: selectedItem.tag,
                      specializationId: selectedItem.value,
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}