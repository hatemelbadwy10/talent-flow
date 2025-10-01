import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/home/widgets/service_widget.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import 'package:shimmer/shimmer.dart';
import '../../../components/grid_list_animator.dart';
import '../../../data/config/di.dart';
import '../model/home_model.dart';

class ServiceCategoriesGrid extends StatelessWidget {
  final List<Category> serviceData;

  const ServiceCategoriesGrid({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    if (serviceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridListAnimatorWidget(
      columnCount: 4,
      aspectRatio: .50,
      padding: const EdgeInsets.all(2),
      items: serviceData.map((data) {
        return GestureDetector(
          onTap: () {
            log("sl ${sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer)} ");
            if (sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                true) {
              CustomNavigator.push(Routes.ownerProjects,arguments: {
                "categoryName": data.name,
                "from_category": true,"categoryId": data.id});
            } else {
              CustomNavigator.push(Routes.freelancers,
                  arguments: {"from_category": true,"categoryId": data.id}); // Adjust route as needed
            }
          },
          child: ServiceWidget(
            iconPath: data.icon ?? 'assets/svgs/default_icon.svg',
            // Use actual icon
            label:
                data.name?.tr() ?? 'N/A'.tr(), // Use actual name and translate
          ),
        );
      }).toList(),
    );
  }
}

// Shimmer version for Service Categories Grid
class ServiceCategoriesGridShimmer extends StatelessWidget {
  const ServiceCategoriesGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridListAnimatorWidget(
        columnCount: 4,
        aspectRatio: .50,
        padding: const EdgeInsets.all(2),
        items: List.generate(
            8,
            (index) => // Generate 8 shimmer items
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 10,
                      color: Colors.white,
                    ),
                  ],
                )).toList(),
      ),
    );
  }
}
