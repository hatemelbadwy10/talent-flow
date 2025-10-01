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
import '../../../data/config/di.dart';
import '../../projects/model/my_projects_model.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../../setting/widgets/setting_app_bar.dart';
import '../bloc/new_projects_bloc.dart';
import '../widgets/project_card.dart';
import 'package:easy_localization/easy_localization.dart';

class NewProject extends StatelessWidget {
  const NewProject({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      NewProjectsBloc(sl<NewProjectsRepo>())..add(Add()), // يبدأ يجيب البيانات
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: CustomAppBar(
          title: 'new_project.title'.tr(),
          showBackButton: false,
          actions: [
            if (!(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false))
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
                      CustomNavigator.push(Routes.addProject);
                    },
                  ),
                ),
              ),
          ],
        ),        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
          child: BlocBuilder<NewProjectsBloc, AppState>(
            builder: (context, state) {
              if (state is Loading) {
                return const ProjectCardShimmer();
              } else if (state is Error) {
                return const Center(child: Text("حدث خطأ أثناء تحميل المشاريع"));
              } else if (state is Done) {
                final projects = state.list as List<MyProjectsModel>;

                if (projects.isEmpty) {
                  return const Center(child: Text("لا توجد مشاريع حالياً"));
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
      ),
    );
  }
}
