import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/repo/home_repo.dart';
import 'package:talent_flow/features/home/widgets/new_list_item.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_bloc.dart';
import '../model/home_model.dart';
import '../widgets/freelancer_listview_item.dart';
import '../widgets/jop_offer_listview_item.dart';
import '../widgets/service_category_grid.dart';

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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: BlocBuilder<HomeBloc, AppState>(
                builder: (context, state) {
                  // Add debug logging
                  log('Current state type: ${state.runtimeType}');
                  if (state is Done) {
                    log('Done state model type: ${state.model.runtimeType}');
                    log('Done state model: ${state.model}');
                  }

                  final commonWidgets = [
                    HomeHeader(
                      onNotificationTap: () {
                        CustomNavigator.push(Routes.notifications);
                      },
                    ),
                    CustomTextField(
                      hint: "home.search_service".tr(),
                      sufSvgIcon: "assets/svgs/search.svg",
                      sIconColor: Colors.grey,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: context.locale.languageCode == 'ar'
                          ? [
                              GestureDetector(
                                onTap: () {
                                  // Pass categories list when navigating
                                  if (state is Done &&
                                      state.model is HomeModel) {
                                    final homeModel = state.model as HomeModel;
                                    log('Categories: ${homeModel.categories}');
                                    CustomNavigator.push(
                                      Routes.allCategories,
                                    );
                                  } else {
                                    CustomNavigator.push(Routes.allCategories);
                                  }
                                },
                                child: Text(
                                  "home.view_all".tr(),
                                  style: const TextStyle(
                                    color: Styles.PRIMARY_COLOR,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                "home.service_category".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ]
                          : [
                              Text(
                                "home.service_category".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  CustomNavigator.push(Routes.allCategories);
                                },
                                child: Text(
                                  "home.view_all".tr(),
                                  style: const TextStyle(
                                    color: Styles.PRIMARY_COLOR,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                    ),
                    SizedBox(height: 16.h),
                  ];

                  if (state is Loading) {
                    log('Showing loading state');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...commonWidgets,
                        const ServiceCategoriesGridShimmer(),
                        SizedBox(height: 24.h),
                        Text(
                          "home.whats_new".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 200.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: const NewListItemShimmer(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildFreelancerHeader(context, isLoading: true),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 250.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: (sl<SharedPreferences>().getBool(
                                            AppStorageKey.isFreelancer) ??
                                        false)
                                    ? const FreelancerListItemShimmer()
                                    : const JobOffererListItemShimmer(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 120.h),
                      ],
                    );
                  } else if (state is Done) {
                    log('Showing done state');

                    // Fix 1: Check if state.model is null first
                    if (state.model == null) {
                      log('state.model is null');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...commonWidgets,
                          const Center(
                              child: Text("No data available - model is null")),
                        ],
                      );
                    }

                    HomeModel? homeModel;
                    try {
                      if (state.model is HomeModel) {
                        homeModel = state.model as HomeModel;
                      } else {
                        log('state.model is not HomeModel, it is: ${state.model.runtimeType}');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...commonWidgets,
                            Center(
                                child: Text(
                                    "Invalid data type: ${state.model.runtimeType}")),
                          ],
                        );
                      }
                    } catch (e) {
                      log('Error casting to HomeModel: $e');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...commonWidgets,
                          Center(child: Text("Error processing data: $e")),
                        ],
                      );
                    }

                    // Add debug logs for the data
                    log('homeModel.categories length: ${homeModel.categories.length}');
                    log('homeModel.cards length: ${homeModel.cards.length}');
                    log('homeModel.top items length: ${homeModel.top?.items.length ?? 0}');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...commonWidgets,

                        homeModel.categories.isNotEmpty
                            ? ServiceCategoriesGrid(
                                serviceData: homeModel.categories)
                            : SizedBox(
                                height: 100.h,
                              ),

                        SizedBox(height: 24.h),
                        Text(
                          "home.whats_new".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Fix 4: Handle empty cards list
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
                        _buildFreelancerHeader(context, isLoading: false),
                        SizedBox(height: 16.h),

                        // Fix 5: Handle empty top items list
                        if (homeModel.top?.items.isNotEmpty ?? false)
                          SizedBox(
                            height: 250.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: homeModel.top!.items.length,
                              itemBuilder: (context, index) {
                                final item = homeModel?.top!.items[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: (sl<SharedPreferences>().getBool(
                                              AppStorageKey.isFreelancer) ??
                                          false)
                                      ? JobOffererListItem(
                                          name: item['name'] ?? 'N/A',
                                          industry:
                                              item['jop_title'] ?? 'General',
                                          imageUrl: item['image'],
                                        )
                                      : FreelancerListItem(
                                          name: item['name'] ?? 'N/A',
                                          jopTitle: item['rating'].toString(),
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

                        SizedBox(height: 120.h),
                      ],
                    );
                  } else if (state is Error) {
                    log('Showing error state');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...commonWidgets,
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Failed to load data. Please try again."),
                        )),
                      ],
                    );
                  }

                  // Fix 6: Better handling of initial/unexpected states
                  log('Showing initial/unexpected state: ${state.runtimeType}');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...commonWidgets,
                      const ServiceCategoriesGridShimmer(),
                      SizedBox(height: 24.h),
                      Text(
                        "home.whats_new".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 200.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: const NewListItemShimmer(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildFreelancerHeader(context, isLoading: true),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 250.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: (sl<SharedPreferences>().getBool(
                                          AppStorageKey.isFreelancer) ??
                                      false)
                                  ? const FreelancerListItemShimmer()
                                  : const JobOffererListItemShimmer(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 120.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreelancerHeader(BuildContext context,
      {required bool isLoading}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: context.locale.languageCode == 'ar'
          ? [
              GestureDetector(
                onTap: () {
                  if (!isLoading) {
                    CustomNavigator.push(Routes.freelancers);
                  }
                },
                child: Text(
                  "home.view_all".tr(),
                  style: TextStyle(
                    color: isLoading ? Colors.grey : Styles.PRIMARY_COLOR,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                "home.freelancers".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ]
          : [
              Text(
                !(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                        false)
                    ? "home.freelancers".tr()
                    : "home.entrepreneur".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              (sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                      false)
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: () {
                        if (!isLoading) {
                          CustomNavigator.push(Routes.freelancers);
                        }
                      },
                      child: Text(
                        "home.view_all".tr(),
                        style: TextStyle(
                          color: isLoading ? Colors.grey : Styles.PRIMARY_COLOR,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/Talent Flow logo 1 1.png",
                height: 30,
              ),
              SizedBox(width: 8.w),
              Text(
                "home.welcome".tr(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: onNotificationTap,
          ),
        ],
      ),
    );
  }
}
