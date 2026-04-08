import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/setting/widgets/multi_select_skills_dialog.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';
import 'section_label_widget.dart';

class SkillsDropdown extends StatelessWidget {
  final Map<String, String> availableSkills;

  const SkillsDropdown({
    super.key,
    required this.availableSkills,
  });

  @override
  Widget build(BuildContext context) {
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
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final resultNames = await showDialog<List<String>>(
                      context: context,
                      builder: (dialogContext) => MultiSelectSkillsDialog(
                        allSkills: availableSkills.values.toList(),
                        initialSelectedSkills: selectedSkillNames,
                      ),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    if (resultNames == null) {
                      return;
                    }

                    final updatedSkills = availableSkills.entries
                        .where((entry) => resultNames.contains(entry.value))
                        .map((entry) => int.parse(entry.key))
                        .toList();

                    context.read<AddProjectBloc>().add(
                          UpdateSkills(
                            skills: updatedSkills,
                            skillNames: resultNames,
                          ),
                        );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Styles.FILL_COLOR,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Styles.LIGHT_BORDER_COLOR),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dropdownName,
                            style: TextStyle(
                              color: selectedSkillNames.isEmpty
                                  ? Styles.DISABLED
                                  : Styles.PRIMARY_COLOR,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Styles.ACCENT_COLOR,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: state.skills.map((id) {
                    final skillName = availableSkills[id.toString()] ?? '';
                    return Chip(
                      label: Text(skillName),
                      onDeleted: () {
                        final updatedSkills = List<int>.from(state.skills)
                          ..remove(id);

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
