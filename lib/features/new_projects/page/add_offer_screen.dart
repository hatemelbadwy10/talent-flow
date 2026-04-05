import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. Import the package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/new_projects/widgets/add_offer_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_description.dart';

import '../../../data/config/di.dart';
import '../../projects/bloc/my_projects_bloc.dart';
import '../../projects/bloc/my_projects_event.dart';
import '../../projects/bloc/my_projects_state.dart';
import '../widgets/project_details_card.dart';

class AddOfferScreen extends StatelessWidget {
  final Map<String, dynamic>? argument;

  const AddOfferScreen({super.key, this.argument});

  @override
  Widget build(BuildContext context) {
    final projectId = argument?['id'] as int?;
    if (projectId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('projectData'.tr()),
          centerTitle: true,
          surfaceTintColor: Colors.white,
        ),
        body: Center(child: Text("error.loading".tr())),
      );
    }

    return BlocProvider(
      create: (context) =>
          MyProjectsBloc(sl())..add(ProjectDetailsRequested(projectId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
              sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                      true
                  ? 'submit_offer_title'.tr()
                  : 'projectData'.tr()),
          centerTitle: true,
          surfaceTintColor: Colors.white,
        ),
        body: BlocBuilder<MyProjectsBloc, MyProjectsState>(
          builder: (context, state) {
            if (state is ProjectDetailsLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectDetailsCard(
                        singleProjectModel: state.project,
                      ),
                      ProjectDescription(
                        singleProjectModel: state.project,
                      ),
                      sl<SharedPreferences>()
                                  .getBool(AppStorageKey.isFreelancer) ??
                              true
                          ? AddOfferWidget(
                              id: projectId,
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is MyProjectsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MyProjectsFailure) {
              return Center(child: Text("error.loading".tr()));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
