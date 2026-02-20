import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/repo/home_repo.dart';
import 'package:talent_flow/features/home/widgets/new_list_item.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_bloc.dart';
import '../model/home_model.dart';
import '../widgets/freelancer_listview_item.dart';
import '../widgets/jop_offer_listview_item.dart';
import '../widgets/home_section_header.dart';
import '../widgets/partners_section.dart';
import '../widgets/service_category_grid.dart';
import '../widgets/home_view_sections.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(homeRepo: sl<HomeRepo>())..add(Add()),
      child: Scaffold(
      
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: BlocBuilder<HomeBloc, AppState>(
            builder: (context, state) {
              final isFreelancer = sl<SharedPreferences>()
                      .getBool(AppStorageKey.isFreelancer) ??
                  false;
                  
              if (state is Loading) {
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
              } else if (state is Done) {
                log('Showing done state');
                  
                // Fix 1: Check if state.model is null first
                if (state.model == null) {
                  log('state.model is null');
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       HomeCommonHeader(),
                       Center(
                          child: Text("No data available - model is null")),
                    ],
                  );
                }
                  
                HomeModel? homeModel;
                try {
                  if (state.model is HomeModel) {
                    homeModel = state.model as HomeModel;
                  } else {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         HomeCommonHeader(),
                      
                      ],
                    );
                  }
                } catch (e) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       HomeCommonHeader(),
                    ],
                  );
                }
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
                                      final card = homeModel?.cards[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 12.w),
                                        child: NewListItem(
                                          title: card?.title ?? 'No Title',
                                          imageUrl: card?.image ?? '',
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
                                ? "home.entrepreneur"
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
                                  final item = homeModel?.top!.items[index];
                                  final parsedJobTitle =
                                      item?['job_title']?.toString().trim() ?? '';
                                  log("item: $item");
                                  log("jop_title: ${item?['job_title']}");
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: isFreelancer
                                        ? JobOffererListItem(
                                            name: item['name'] ?? 'N/A',
                                            industry:
                                                item['jop_title'] ?? 'General',
                                            imageUrl: item['image'],
                                          )
                                        : FreelancerListItem(
                                            id: item['id'],
                                            name: item['name'] ?? 'N/A',
                                            jopTitle: parsedJobTitle.isNotEmpty
                                                ? parsedJobTitle
                                                : 'home.job_title_not_set'.tr(),
                                            rating:item['rating'] != null ? double.tryParse(item['rating'].toString()) : null,
                                            imageUrl: item['image'],
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
                          const PartnersSection(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is Error) {
                log('Showing error state');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeCommonHeader(),
                    const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Failed to load data. Please try again."),
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
