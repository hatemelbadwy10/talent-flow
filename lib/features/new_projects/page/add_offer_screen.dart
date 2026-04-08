import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/new_projects/widgets/add_offer_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_description.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../projects/bloc/my_projects_bloc.dart';
import '../../projects/model/single_project_model.dart';
import '../widgets/project_details_card.dart';

class AddOfferScreen extends StatelessWidget {
  final Map<String, dynamic>? argument;

  const AddOfferScreen({super.key, this.argument});

  int? _currentUserId() {
    final rawUserId = sl<SharedPreferences>().getString(AppStorageKey.userId);
    return int.tryParse(rawUserId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? true;

    return BlocProvider(
      create: (context) =>
          MyProjectsBloc(sl())..add(Click(arguments: argument?['id'])),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<MyProjectsBloc, AppState>(
            builder: (context, state) {
              final project = state is Done ? state.model as SingleProjectModel : null;
              final myProposal = isFreelancer
                  ? _findMyProposal(project)
                  : null;
              final hasEditArguments = argument?['proposalId'] != null;
              final title = !isFreelancer
                  ? 'projectData'.tr()
                  : (hasEditArguments || myProposal != null
                      ? 'update_offer_title'.tr()
                      : 'submit_offer_title'.tr());

              return AppBar(
                backgroundColor: Colors.white,
                title: Text(title),
                centerTitle: true,
                surfaceTintColor: Colors.white,
              );
            },
          ),
        ),
        body: BlocBuilder<MyProjectsBloc, AppState>(
          builder: (context, state) {
            if (state is Done) {
              final project = state.model as SingleProjectModel;
              final myProposal = isFreelancer ? _findMyProposal(project) : null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectDetailsCard(
                        singleProjectModel: project,
                      ),
                      ProjectDescription(
                        singleProjectModel: project,
                      ),
                      isFreelancer
                          ? AddOfferWidget(
                              id: argument?['id'],
                              proposalId:
                                  argument?['proposalId'] as int? ?? myProposal?.id,
                              initialDescription:
                                  argument?['initialDescription'] as String? ??
                                      myProposal?.description,
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is Error) {
              return Center(child: Text("error.loading".tr()));
            }
            return Container();
          },
        ),
      ),
    );
  }

  ProjectProposal? _findMyProposal(SingleProjectModel? project) {
    if (project == null) {
      return null;
    }

    final currentUserId = _currentUserId();
    for (final proposal in project.proposals) {
      if (proposal.freelancerId == currentUserId) {
        return proposal;
      }
    }
    return null;
  }
}
