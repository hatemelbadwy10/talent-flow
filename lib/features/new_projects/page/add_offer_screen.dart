import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/add_offer_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_description.dart';

import '../../projects/bloc/project_details_bloc.dart';
import '../../projects/model/single_project_model.dart';
import '../../projects/model/project_route_args.dart';
import '../../projects/repo/projects_repository.dart';
import '../../projects/widgets/project_files_section.dart';
import '../widgets/project_details_card.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class AddOfferScreen extends StatelessWidget {
  final OfferRouteArgs argument;
  final ProjectsRepository projectRepository;
  final int? currentUserId;
  final bool isFreelancer;

  const AddOfferScreen({
    super.key,
    required this.argument,
    required this.projectRepository,
    required this.currentUserId,
    required this.isFreelancer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectDetailsBloc(
        repository: projectRepository,
      )..add(ProjectDetailsRequested(argument.projectId)),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
            builder: (context, state) {
              final project =
                  state is ProjectDetailsLoaded ? state.project : null;
              final myProposal = isFreelancer ? _findMyProposal(project) : null;
              final hasEditArguments = argument.proposalId != null;
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
        body: BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
          builder: (context, state) {
            if (state is ProjectDetailsLoaded) {
              final project = state.project;
              final myProposal = isFreelancer ? _findMyProposal(project) : null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectDetailsCard(
                        singleProjectModel: project,
                        onOwnerTap: isFreelancer && project.owner?.id != null
                            ? () {
                                CustomNavigator.push(
                                  Routes.entrepreneur,
                                  arguments: {
                                    'entrepreneurId': project.owner!.id,
                                  },
                                );
                              }
                            : null,
                      ),
                      ProjectDescription(
                        singleProjectModel: project,
                        showAttachments: false,
                      ),
                      if (project.files.isNotEmpty)
                        ProjectFilesSection(files: project.files),
                      isFreelancer
                          ? AddOfferWidget(
                              id: argument.projectId,
                              proposalId: argument.proposalId ?? myProposal?.id,
                              initialDescription: argument.initialDescription ??
                                  myProposal?.description,
                              questions: project.questions,
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProjectDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProjectDetailsFailed) {
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

    for (final proposal in project.proposals) {
      if (proposal.freelancerId == currentUserId) {
        return proposal;
      }
    }
    return null;
  }
}
