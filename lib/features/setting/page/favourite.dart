import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/home/widgets/freelancer_listview_item.dart';
import 'package:talent_flow/features/new_projects/widgets/project_card.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../home/model/freelancers_model.dart';
import '../bloc/fav_bloc.dart';
import '../model/favourite_model.dart';
import '../widgets/favourite_work_card.dart';
import '../widgets/setting_app_bar.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;
    final tabs = isFreelancer
        ? [
            SizedBox(
              width: 140,
              child: Tab(text: 'favourite_tabs.projects'.tr()),
            ),
          ]
        : [
            SizedBox(
              width: 140,
              child: Tab(text: 'favourite_tabs.works'.tr()),
            ),
            SizedBox(
              width: 140,
              child: Tab(text: 'favourite_tabs.freelancers'.tr()),
            ),
            SizedBox(
              width: 140,
              child: Tab(text: 'favourite_tabs.projects'.tr()),
            ),
          ];

    return BlocProvider(
      create: (context) => FavBloc(sl())..add(Add()),
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'favourite'.tr(),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorColor: Styles.PRIMARY_COLOR,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Styles.PRIMARY_COLOR,
                  unselectedLabelColor: Styles.BLACK,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  tabs: tabs,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<FavBloc, AppState>(
                    builder: (context, state) {
                      if (state is Loading) {
                        return const ProjectCardShimmer();
                      }

                      if (state is Error) {
                        return Center(
                          child: Text(
                            'something_went_wrong'.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      if (state is Done &&
                          state.model is FavouriteResponseModel) {
                        final model = state.model! as FavouriteResponseModel;
                        final canToggleFreelancerAndWork = !isFreelancer;
                        final tabViews = isFreelancer
                            ? [
                                _buildProjectsTab(
                                    context, model.payload.projects),
                              ]
                            : [
                                _buildWorksTab(
                                  context,
                                  model.payload.works,
                                  canToggleFavourite:
                                      canToggleFreelancerAndWork,
                                ),
                                _buildFreelancersTab(
                                  context,
                                  model.payload.freelancers,
                                  canToggleFavourite:
                                      canToggleFreelancerAndWork,
                                ),
                                _buildProjectsTab(
                                    context, model.payload.projects),
                              ];
                        return TabBarView(
                          children: tabViews,
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

  Widget _buildProjectsTab(
      BuildContext blocContext, List<MyProjectsModel> projects) {
    if (projects.isEmpty) {
      return const _EmptyFavouriteView(
        messageKey: 'no_favourite_projects',
      );
    }

    return ListView.separated(
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (itemContext, index) {
        final project = projects[index];
        return ProjectCard(
          projectsModel: project.copyWith(isInFavorites: true),
          onToggleFavourite: project.id == null
              ? null
              : () {
                  blocContext.read<FavBloc>().add(
                        Update(
                          arguments: {
                            'type': 'project',
                            'id': project.id,
                          },
                        ),
                      );
                },
        );
      },
    );
  }

  Widget _buildFreelancersTab(
    BuildContext blocContext,
    List<FreelancersModel> freelancers, {
    required bool canToggleFavourite,
  }) {
    if (freelancers.isEmpty) {
      return const _EmptyFavouriteView(
        messageKey: 'favourite_screen.no_favourite_freelancers',
      );
    }

    return ListView.separated(
      itemCount: freelancers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (itemContext, index) {
        final freelancer = freelancers[index];
        final jobTitle = freelancer.jobTitle?.trim() ?? '';
        return FreelancerListItem(
          id: freelancer.id ?? 0,
          name: freelancer.name ?? '-',
          jopTitle:
              jobTitle.isNotEmpty ? jobTitle : "home.job_title_not_set".tr(),
          rating: freelancer.rating?.toDouble(),
          imageUrl: freelancer.image,
          cardWidth: double.infinity,
          isInFavorites: true,
          onToggleFavourite: canToggleFavourite && freelancer.id != null
              ? () {
                  blocContext.read<FavBloc>().add(
                        Update(
                          arguments: {
                            'type': 'freelancer',
                            'id': freelancer.id,
                          },
                        ),
                      );
                }
              : null,
        );
      },
    );
  }

  Widget _buildWorksTab(
    BuildContext blocContext,
    List<FavouriteWorkModel> works, {
    required bool canToggleFavourite,
  }) {
    if (works.isEmpty) {
      return const _EmptyFavouriteView(
        messageKey: 'favourite_screen.no_favourite_works',
      );
    }

    return ListView.separated(
      itemCount: works.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (itemContext, index) {
        final work = works[index];
        return FavouriteWorkCard(
          work: work,
          onToggleFavourite: canToggleFavourite && work.id != null
              ? () {
                  blocContext.read<FavBloc>().add(
                        Update(
                          arguments: {
                            'type': 'work',
                            'id': work.id,
                          },
                        ),
                      );
                }
              : null,
        );
      },
    );
  }
}

class _EmptyFavouriteView extends StatelessWidget {
  const _EmptyFavouriteView({
    required this.messageKey,
  });

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/empty_list.png'),
          SizedBox(height: 16.h),
          Text(
            messageKey.tr(),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
