import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/repo/home_dashboard_repository.dart';
import 'package:talent_flow/features/home/widgets/new_list_item.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_dashboard_bloc.dart';
import '../bloc/home_dashboard_event.dart';
import '../bloc/home_dashboard_state.dart';
import '../model/home_model.dart';
import '../widgets/freelancer_listview_item.dart';
import '../widgets/jop_offer_listview_item.dart';
import '../widgets/home_section_header.dart';
import '../widgets/partners_section.dart';
import '../widgets/service_category_grid.dart';
import '../widgets/home_view_sections.dart';
import '../../setting/repo/favourites_repository.dart';

class HomeView extends StatefulWidget {
  final HomeDashboardRepository repository;
  final FavouritesRepository favouritesRepository;
  final bool isFreelancer;

  const HomeView({
    super.key,
    required this.repository,
    required this.favouritesRepository,
    required this.isFreelancer,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeDashboardBloc(
        repository: widget.repository,
      )..add(const HomeDashboardRequested()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
            builder: (context, state) {
              final isFreelancer = widget.isFreelancer;

              if (state is HomeDashboardLoading) {
                log('Showing loading state');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeCommonHeader(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: HomeLoadingBody(isFreelancer: isFreelancer),
                    ),
                  ],
                );
              } else if (state case HomeDashboardLoaded(:final dashboard)) {
                log('Showing done state');
                final HomeModel homeModel = dashboard;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeCommonHeader(homeModel: homeModel),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          homeModel.categories.isNotEmpty
                              ? ServiceCategoriesGrid(
                                  serviceData: homeModel.categories)
                              : SizedBox(
                                  height: 100.h,
                                ),
                          SizedBox(height: 24.h),
                          const HomeSectionHeader(
                            titleKey: "home.whats_new",
                            showViewAll: false,
                          ),
                          SizedBox(height: 16.h),
                          homeModel.cards.isNotEmpty
                              ? SizedBox(
                                  height: 200.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homeModel.cards.length,
                                    itemBuilder: (context, index) {
                                      final card = homeModel.cards[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 12.w),
                                        child: NewListItem(
                                          title: card.title ?? 'No Title',
                                          imageUrl: card.image ?? '',
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox(
                                  height: 200.h,
                                ),
                          SizedBox(height: 24.h),
                          HomeSectionHeader(
                            titleKey: isFreelancer
                                ? "home.entrepreneurs"
                                : "home.freelancers",
                            isLoading: false,
                            showViewAll: !isFreelancer,
                            onViewAll: () {
                              CustomNavigator.push(Routes.freelancers);
                            },
                          ),
                          SizedBox(height: 16.h),
                          if (homeModel.top?.items.isNotEmpty ?? false)
                            SizedBox(
                              height: 220.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: homeModel.top!.items.length,
                                itemBuilder: (context, index) {
                                  final item = homeModel.top!.items[index];
                                  final parsedEntrepreneurTitle =
                                      item?['job_title']?.toString().trim() ??
                                          item?['jop_title']
                                              ?.toString()
                                              .trim() ??
                                          '';
                                  final parsedJobTitle =
                                      item?['job_title']?.toString().trim() ??
                                          '';
                                  log("item: $item");
                                  log("jop_title: ${item?['job_title']}");
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: isFreelancer
                                        ? JobOffererListItem(
                                            name: item['name'] ?? 'N/A',
                                            industry: parsedEntrepreneurTitle
                                                    .isNotEmpty
                                                ? parsedEntrepreneurTitle
                                                : 'home.job_title_not_set'.tr(),
                                            imageUrl: item['image'],
                                            onTap: item['id'] == null
                                                ? null
                                                : () {
                                                    CustomNavigator.push(
                                                      Routes.entrepreneur,
                                                      arguments: {
                                                        'entrepreneurId':
                                                            item['id'],
                                                      },
                                                    );
                                                  },
                                          )
                                        : FreelancerListItem(
                                            id: item['id'],
                                            name: item['name'] ?? 'N/A',
                                            jopTitle: parsedJobTitle.isNotEmpty
                                                ? parsedJobTitle
                                                : 'home.job_title_not_set'.tr(),
                                            rating: item['rating'] != null
                                                ? double.tryParse(
                                                    item['rating'].toString())
                                                : null,
                                            imageUrl: item['image'],
                                            isInFavorites:
                                                (item['is_in_favorites'] ??
                                                            item['is_fav']) ==
                                                        true ||
                                                    (item['is_in_favorites'] ??
                                                            item['is_fav']) ==
                                                        1 ||
                                                    (item['is_in_favorites'] ??
                                                                item['is_fav'])
                                                            ?.toString() ==
                                                        '1',
                                            onToggleFavourite: () async {
                                              final result = await widget
                                                  .favouritesRepository
                                                  .toggleFreelancerFavourite(
                                                item['id'],
                                              );
                                              return result.isRight();
                                            },
                                          ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 250.h,
                            ),
                          SizedBox(height: 24.h),
                          PartnersSection(partners: homeModel.partners),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is HomeDashboardFailed) {
                log('Showing error state');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeCommonHeader(),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("failed_to_load_data".tr()),
                    )),
                    SizedBox(height: 24.h), // Spacing before Partners section
                    const PartnersSection(), // New Partners section
                    SizedBox(height: 120.h),
                  ],
                );
              }

              // Fix 6: Better handling of initial/unexpected states
              log('Showing initial/unexpected state: ${state.runtimeType}');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeCommonHeader(),
                  HomeLoadingBody(isFreelancer: isFreelancer),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
