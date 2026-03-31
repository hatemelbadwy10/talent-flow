import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../../auth/pages/social_media_login/repo/chat_repo.dart';
import '../../new_projects/widgets/project_description.dart';
import '../../new_projects/widgets/project_details_card.dart';
import '../bloc/my_projects_bloc.dart';
import '../model/single_project_model.dart';
import '../widgets/single_project_shimmer.dart';

class SingleProjectView extends StatelessWidget {
  final Map<String, dynamic> arguments;

  const SingleProjectView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    final bool isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;

    return BlocProvider(
      create: (context) => MyProjectsBloc(sl())
        ..add(Click(arguments: arguments['id'])), // 👈 هنا
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('project_details'.tr()),
          centerTitle: true,
          surfaceTintColor: Colors.white,
        ),
        body: BlocBuilder<MyProjectsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const SingleProjectViewShimmer();
            } else if (state is Error) {
              return const Center(child: Text("فشل تحميل المشروع"));
            } else if (state is Done && state.model is SingleProjectModel) {
              final project = state.model as SingleProjectModel;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectDetailsCard(
                        singleProjectModel: project,
                      ),
                      ProjectDescription(singleProjectModel: project),
                      if (!isFreelancer)
                        _ProjectProposalsSection(
                          proposals: project.proposals,
                          projectId: arguments['id'] as int?,
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ProjectProposalsSection extends StatelessWidget {
  const _ProjectProposalsSection({
    required this.proposals,
    required this.projectId,
  });

  final List<ProjectProposal> proposals;
  final int? projectId;

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          '${'project_proposals.title'.tr()} (${proposals.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Styles.HEADER,
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: proposals.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            return _ProposalCard(
              proposal: proposal,
              projectId: projectId,
            );
          },
        ),
      ],
    );
  }
}

class _ProposalCard extends StatefulWidget {
  const _ProposalCard({
    required this.proposal,
    required this.projectId,
  });

  final ProjectProposal proposal;
  final int? projectId;

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  bool _isStartingChat = false;

  Future<void> _startChat() async {
    final freelancerId = widget.proposal.freelancerId;
    if (_isStartingChat || freelancerId == null) {
      return;
    }

    setState(() {
      _isStartingChat = true;
    });

    final result = await sl<ChatRepo>().startConversation(
      userId: freelancerId,
      projectId: widget.projectId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isStartingChat = false;
    });

    result.fold(
      (failure) {
        AppCore.showSnackBar(
          notification: AppNotification(
            message: failure.error,
            backgroundColor: Colors.red.shade50,
            borderColor: Colors.red.shade200,
          ),
        );
      },
      (conversationId) {
        CustomNavigator.push(
          Routes.chat,
          arguments: {
            'conversationId': conversationId,
            'freelancerId': freelancerId,
            'freelancerName': widget.proposal.freelancerName,
            'freelancerJobTitle': widget.proposal.freelancerJobTitle,
            'projectId': widget.projectId,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final proposal = widget.proposal;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: proposal.freelancerId == null
          ? null
          : () {
              CustomNavigator.push(
                Routes.freeLancerView,
                arguments: {
                  'freelancerId': proposal.freelancerId,
                },
              );
            },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Styles.BORDER_COLOR),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                  backgroundImage: proposal.freelancerImage != null &&
                          proposal.freelancerImage!.trim().isNotEmpty
                      ? NetworkImage(proposal.freelancerImage!)
                      : null,
                  child: proposal.freelancerImage == null ||
                          proposal.freelancerImage!.trim().isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Styles.PRIMARY_COLOR,
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.freelancerName ?? 'no_name'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Styles.HEADER,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 6.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.work_outline,
                                size: 15,
                                color: Styles.HINT_COLOR,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                (proposal.freelancerJobTitle ?? '')
                                        .trim()
                                        .isEmpty
                                    ? 'no_job_title'.tr()
                                    : proposal.freelancerJobTitle!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Styles.SUBTITLE,
                                ),
                              ),
                            ],
                          ),
                          if (proposal.freelancerRating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  proposal.freelancerRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Styles.SUBTITLE,
                                  ),
                                ),
                              ],
                            ),
                          if ((proposal.since ?? '').trim().isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 15,
                                  color: Styles.HINT_COLOR,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  proposal.since!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Styles.HINT_COLOR,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _startChat,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _isStartingChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Styles.PRIMARY_COLOR,
                              ),
                            )
                          : const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: Styles.PRIMARY_COLOR,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            if ((proposal.description ?? '').trim().isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                proposal.description!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Styles.SUBTITLE,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
