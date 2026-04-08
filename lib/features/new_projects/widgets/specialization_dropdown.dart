import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/new_projects/widgets/section_label_widget.dart';
import 'package:talent_flow/features/setting/widgets/single_select_dialoug.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_event.dart';
import '../bloc/add_project_state.dart';

class SpecializationDropdown extends StatelessWidget {
  final Map<String, String> specializations;

  const SpecializationDropdown({
    super.key,
    required this.specializations,
  });

  @override
  Widget build(BuildContext context) {
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
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final selectedId = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) => SingleSelectDialog(
                    title: 'add_project.specialization'.tr(),
                    options: specializations,
                    initialSelectedId: state.specializationId?.toString(),
                  ),
                );

                if (!context.mounted) {
                  return;
                }

                if (selectedId == null ||
                    !specializations.containsKey(selectedId)) {
                  return;
                }

                context.read<AddProjectBloc>().add(
                      UpdateSpecializationId(
                        specializationId: int.tryParse(selectedId),
                        specializationName: specializations[selectedId],
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
                        state.specializationName ??
                            'add_project.select_specialization'.tr(),
                        style: TextStyle(
                          color: state.specializationName == null
                              ? Styles.DISABLED
                              : Styles.PRIMARY_COLOR,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Styles.ACCENT_COLOR,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
