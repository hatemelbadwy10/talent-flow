import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_bloc.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';
import 'package:talent_flow/features/new_projects/repo/selection_option_repo.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/features/setting/widgets/single_select_dialoug.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../widgets/project_card.dart';

class NewProject extends StatefulWidget {
  const NewProject({super.key});

  @override
  State<NewProject> createState() => _NewProjectState();
}

class _NewProjectState extends State<NewProject> {
  static const Map<String, String> _sortOptions = {
    'latest': 'new_project.latest',
    'oldest': 'new_project.oldest',
  };

  late final NewProjectsBloc _projectsBloc;
  late final Future<SelectionModel> _selectionFuture;
  int? _selectedSpecializationId;
  String? _selectedSpecializationName;
  String? _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _projectsBloc = NewProjectsBloc(sl<NewProjectsRepo>())..add(Add());
    _selectionFuture = sl<SelectionOptionRepo>().getSelectionOption().then(
      (result) => result.fold((failure) => throw failure, (model) => model),
    );
  }

  @override
  void dispose() {
    _projectsBloc.close();
    super.dispose();
  }

  void _fetchProjects() {
    _projectsBloc.add(
      Add(
        arguments: {
          'specialization': _selectedSpecializationId,
          'sortBy': _selectedSortBy,
        },
      ),
    );
  }

  Future<void> _selectSpecialization() async {
    final selection = await _selectionFuture;
    if (!mounted) {
      return;
    }

    final selectedId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SingleSelectDialog(
        title: 'new_project.filter_specialization'.tr(),
        options: selection.specializations,
        initialSelectedId: _selectedSpecializationId?.toString(),
      ),
    );

    if (!mounted || selectedId == null) {
      return;
    }

    setState(() {
      _selectedSpecializationId = int.tryParse(selectedId);
      _selectedSpecializationName = selection.specializations[selectedId];
    });
    _fetchProjects();
  }

  Future<void> _selectSortBy() async {
    final selectedId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SingleSelectDialog(
        title: 'new_project.sort_by'.tr(),
        options: _sortOptions.map(
          (key, value) => MapEntry(key, value.tr()),
        ),
        initialSelectedId: _selectedSortBy,
      ),
    );

    if (!mounted || selectedId == null) {
      return;
    }

    setState(() {
      _selectedSortBy = selectedId;
    });
    _fetchProjects();
  }

  void _clearFilters() {
    setState(() {
      _selectedSpecializationId = null;
      _selectedSpecializationName = null;
      _selectedSortBy = null;
    });
    _fetchProjects();
  }

  bool get _hasFilters =>
      _selectedSpecializationId != null || _selectedSortBy != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _projectsBloc,
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
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 22,
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
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                FutureBuilder<SelectionModel>(
                  future: _selectionFuture,
                  builder: (context, snapshot) {
                    return _FiltersBar(
                      specializationLabel: _selectedSpecializationName,
                      sortLabel: _selectedSortBy == null
                          ? null
                          : _sortOptions[_selectedSortBy!]?.tr(),
                      showClear: _hasFilters,
                      specializationsReady: snapshot.hasData,
                      onSpecializationTap:
                          snapshot.hasData ? _selectSpecialization : null,
                      onSortTap: _selectSortBy,
                      onClearTap: _clearFilters,
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
                          child: Text('failed_to_load_projects'.tr()),
                        );
                      } else if (state is Done) {
                        final projects = state.list as List<MyProjectsModel>;

                        if (projects.isEmpty) {
                          return Center(
                            child: Text('no_projects_available'.tr()),
                          );
                        }

                        return ListAnimator(
                          data: projects
                              .map(
                                (project) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
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
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.specializationLabel,
    required this.sortLabel,
    required this.showClear,
    required this.specializationsReady,
    required this.onSpecializationTap,
    required this.onSortTap,
    required this.onClearTap,
  });

  final String? specializationLabel;
  final String? sortLabel;
  final bool showClear;
  final bool specializationsReady;
  final VoidCallback? onSpecializationTap;
  final VoidCallback onSortTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FilterChipButton(
                label: specializationLabel ??
                    'new_project.filter_specialization'.tr(),
                icon: Icons.category_outlined,
                onTap: onSpecializationTap,
                enabled: specializationsReady,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterChipButton(
                label: sortLabel ?? 'new_project.sort_by'.tr(),
                icon: Icons.swap_vert_rounded,
                onTap: onSortTap,
              ),
            ),
            if (showClear) ...[
              const SizedBox(width: 12),
              _ResetFilterButton(
                onTap: onClearTap,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Styles.LIGHT_BORDER_COLOR),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? Styles.PRIMARY_COLOR : Styles.DISABLED,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Styles.HEADER : Styles.DISABLED,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? Styles.ACCENT_COLOR : Styles.DISABLED,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetFilterButton extends StatelessWidget {
  const _ResetFilterButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Styles.LIGHT_BORDER_COLOR),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh_rounded,
                color: Styles.IN_ACTIVE,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                'new_project.reset'.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Styles.IN_ACTIVE,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
