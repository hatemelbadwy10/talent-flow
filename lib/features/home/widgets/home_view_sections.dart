import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/model/home_model.dart';
import 'package:talent_flow/features/home/widgets/home_header.dart';
import 'package:talent_flow/features/home/widgets/home_section_header.dart';
import 'package:talent_flow/features/home/widgets/jop_offer_listview_item.dart';
import 'package:talent_flow/features/home/widgets/new_list_item.dart';
import 'package:talent_flow/features/home/widgets/partners_section.dart';
import 'package:talent_flow/features/home/widgets/service_category_grid.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';

import 'freelancer_listview_item.dart';

class HomeCommonHeader extends StatelessWidget {
  final HomeModel? homeModel;

  const HomeCommonHeader({super.key, this.homeModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar (separate full-width component)        // Header Section with user info and actions
        HomeHeaderSection(
          onNotificationTap: () {
            CustomNavigator.push(Routes.notifications);
          },
          onMessageTap: () {
            // Navigate to messages if route exists, otherwise just handle it
          },
          userName: UserBloc.instance.user?.name,
          userImage: UserBloc.instance.user?.profileImage,
          notificationCount: 0,
          messageCount: 0,
        ),
        SizedBox(height: 24.h),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.w),
          child: HomeSectionHeader(
            titleKey: "home.service_category",
            onViewAll: () {
              if (homeModel != null) {
                log('Categories: ${homeModel!.categories}');
              }
              CustomNavigator.push(Routes.allCategories);
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class HomeLoadingBody extends StatelessWidget {
  final bool isFreelancer;

  const HomeLoadingBody({super.key, required this.isFreelancer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceCategoriesGridShimmer(),
          SizedBox(height: 24.h),
          const HomeSectionHeader(
            titleKey: "home.whats_new",
            showViewAll: false,
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
          HomeSectionHeader(
            titleKey: isFreelancer ? "home.entrepreneur" : "home.freelancers",
            isLoading: true,
            showViewAll: !isFreelancer,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 250.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: isFreelancer
                      ? const FreelancerListItemShimmer()
                      : const JobOffererListItemShimmer(),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          const PartnersSection(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }
}
