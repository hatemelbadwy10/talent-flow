import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/user_completion_guard.dart';
import '../../../data/config/di.dart';
import '../../projects/model/my_projects_model.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../../setting/widgets/setting_app_bar.dart';
import '../bloc/new_projects_bloc.dart';
import '../bloc/selection_option_bloc.dart';
import '../model/selection_option_model.dart';
import '../widgets/project_card.dart';
import 'package:easy_localization/easy_localization.dart';

class NewProject extends StatefulWidget {
  const NewProject({super.key});

  @override
  State<NewProject> createState() => _NewProjectState();
}

class _NewProjectState extends State<NewProject> {
  int? _specializationId;
  String? _sortBy;

  void _loadProjects(BuildContext context) {
    context.read<NewProjectsBloc>().add(
          Add(
            arguments: {
              'specialization': _specializationId,
              'sortBy': _sortBy,
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NewProjectsBloc(sl<NewProjectsRepo>())..add(Add()),
        ),
        BlocProvider(
          create: (_) => SelectionOptionBloc(sl())..add(Add()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: CustomAppBar(
          title: 'new_project.title'.tr(),
          showBackButton: false,
          actions: [
            if (!(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                false))
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18, // حجم الدائرة
                  backgroundColor: Colors.white, // خلفية الدائرة
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 22, // حجم الأيقونة
                    ),
                    onPressed: () {
                      UserCompletionGuard.ensureCanAddProject(context).then(
                        (allowed) {
                          if (!allowed) return;
                          CustomNavigator.push(Routes.addProject);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
            child: Column(
              children: [
                BlocBuilder<SelectionOptionBloc, AppState>(
                  builder: (context, state) {
                    final specializations =
                        state is Done && state.model is SelectionModel
                            ? (state.model as SelectionModel).specializations
                            : const <String, String>{};
                    return _ProjectFilters(
                      specializations: specializations,
                      specializationId: _specializationId,
                      sortBy: _sortBy,
                      onSpecializationChanged: (value) {
                        setState(() => _specializationId = value);
                        _loadProjects(context);
                      },
                      onSortChanged: (value) {
                        setState(() => _sortBy = value);
                        _loadProjects(context);
                      },
                      onReset: () {
                        setState(() {
                          _specializationId = null;
                          _sortBy = null;
                        });
                        _loadProjects(context);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<NewProjectsBloc, AppState>(
                    builder: (context, state) {
                      if (state is Loading) {
                        return const ProjectCardShimmer();
                      } else if (state is Error) {
                        return Center(
                            child: Text("failed_to_load_projects".tr()));
                      } else if (state is Done) {
                        final projects = state.list as List<MyProjectsModel>;

                        if (projects.isEmpty) {
                          return Center(
                              child: Text("no_projects_available".tr()));
                        }

                        return ListAnimator(
                          data: projects
                              .map(
                                (project) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: ProjectCard(projectsModel: project),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectFilters extends StatelessWidget {
  const _ProjectFilters({
    required this.specializations,
    required this.specializationId,
    required this.sortBy,
    required this.onSpecializationChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  final Map<String, String> specializations;
  final int? specializationId;
  final String? sortBy;
  final ValueChanged<int?> onSpecializationChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey(specializationId),
                  initialValue: specializationId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'new_project.filter_specialization'.tr(),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text('new_project.all_specializations'.tr()),
                    ),
                    ...specializations.entries.map(
                      (entry) => DropdownMenuItem<int>(
                        value: int.tryParse(entry.key),
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: onSpecializationChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(sortBy),
                  initialValue: sortBy,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'new_project.sort_by'.tr(),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('new_project.default_sort'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'latest',
                      child: Text('new_project.latest'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('new_project.oldest'.tr()),
                    ),
                  ],
                  onChanged: onSortChanged,
                ),
              ),
            ],
          ),
          if (specializationId != null || sortBy != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('new_project.reset'.tr()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
