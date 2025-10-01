import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_bloc.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';
import 'package:talent_flow/features/new_projects/widgets/project_card.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_app_bar.dart';
import '../../../data/config/di.dart';
import '../bloc/fav_bloc.dart';
import '../../../app/core/app_state.dart';
import '../../projects/model/my_projects_model.dart';
import '../widgets/setting_app_bar.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => FavBloc(sl())..add(Add()),
),
    BlocProvider(
      create: (context) => NewProjectsBloc(sl()),
    ),
  ],
  child: Scaffold(
        appBar: CustomAppBar(title: 'favourite'.tr()),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<FavBloc, AppState>(
            builder: (context, state) {
              if (state is Loading) {
                return const ProjectCardShimmer();
              } else if (state is Done) {
                final List<MyProjectsModel> projects = state.list as List<MyProjectsModel>;
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/empty_list.png',
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_favourite_projects'.tr(), // لازم تضيف هذا key في JSON
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return ListAnimator(
                  data: projects
                      .map((project) => Column(
                    children: [
                      ProjectCard( projectsModel: project,),
                      const SizedBox(height: 16),
                    ],
                  ))
                      .toList(),
                );
              } else if (state is Error) {
                return Center(
                  child: Text(
                    'something_went_wrong'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
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
