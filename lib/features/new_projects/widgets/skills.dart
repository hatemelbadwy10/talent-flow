// widgets/skills_dropdown.dart
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../components/dynamic_drop_down_button.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import '../model/drop_down_model.dart';
import 'section_label_widget.dart';

class SkillsDropdown extends StatelessWidget {
  final Map<String, String> availableSkills;

  const SkillsDropdown({
    super.key,
    required this.availableSkills,
  });

  @override
  Widget build(BuildContext context) {
    final items = availableSkills.entries
        .map((entry) => DropdownItem(entry.value, value: int.parse(entry.key)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: 'add_project.skills'.tr(),
          isRequired: true,
        ),
        const SizedBox(height: 8),
        BlocBuilder<AddProjectBloc, AddProjectState>(
          buildWhen: (previous, current) => previous.skills != current.skills,
          builder: (context, state) {
            // convert ids to names
            final selectedSkillNames = state.skills
                .map((id) => availableSkills[id.toString()] ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

            final dropdownName = selectedSkillNames.isNotEmpty
                ? selectedSkillNames.join(', ')
                : 'add_project.select_skill'.tr();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic multi-select dropdown
                DynamicDropDownButton(
                  items: items,
                  name: dropdownName,
                  selectedValue: null, // allow multiple
                  onChange: (selectedItem) {
                    if (selectedItem != null) {
                      final updatedSkills = List<int>.from(state.skills);

                      if (!updatedSkills.contains(selectedItem.value)) {
                        updatedSkills.add(selectedItem.value);
                      }

                      // get names of updated skills
                      final updatedSkillNames = updatedSkills
                          .map((id) => availableSkills[id.toString()] ?? '')
                          .where((name) => name.isNotEmpty)
                          .toList();

                      log("selected skills $updatedSkills, names $updatedSkillNames");

                      context.read<AddProjectBloc>().add(
                        UpdateSkills(
                          skills: updatedSkills,
                          skillNames: updatedSkillNames,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 10),

                // Show selected skills as Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: state.skills.map((id) {
                    final skillName = availableSkills[id.toString()] ?? '';
                    return Chip(
                      label: Text(skillName),
                      onDeleted: () {
                        final updatedSkills =
                        List<int>.from(state.skills)..remove(id);

                        final updatedSkillNames = updatedSkills
                            .map((id) => availableSkills[id.toString()] ?? '')
                            .where((name) => name.isNotEmpty)
                            .toList();

                        context.read<AddProjectBloc>().add(
                          UpdateSkills(
                            skills: updatedSkills,
                            skillNames: updatedSkillNames,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
