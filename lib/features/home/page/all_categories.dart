import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../bloc/home_bloc.dart';
import '../model/home_model.dart';
import '../repo/home_repo.dart';

class ServiceCategoryView extends StatelessWidget {
  const ServiceCategoryView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(homeRepo: sl<HomeRepo>())..add(Click()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'all_categories'.tr()),
        body: BlocBuilder<HomeBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is Error) {
              return const Center(child: Text('Error loading categories'));
            } else if (state is Done) {
              final category = state.list as List<Category>;
              return ListView.builder(
                itemCount: category.length,
                itemBuilder: (context, index) {
                  return ServiceCategoryTile(
                      icon: category[index].icon!,
                      title: category[index].name ?? "",
                      subtitle: category[index].description ?? "",
                      onTap: () {
                        if (sl<SharedPreferences>()
                                .getBool(AppStorageKey.isFreelancer) ??
                            false) {
                          CustomNavigator.push(Routes.ownerProjects,
                              arguments: {
                                "categoryName": category[index].name,
                                "categoryId": category[index].id,
                              });
                        } else {
                          CustomNavigator.push(Routes.freelancers, arguments: {
                            "categoryId": category[index].id,
                          });
                        }
                      });
                },
              );
            } else {
              return const Center(child: Text('No categories found'));
            }
          },
        ),
      ),
    );
  }
}

/// A reusable widget for displaying a single service category item.
class ServiceCategoryTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceCategoryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // Icon with a decorated background
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.network(
                icon,
              ),
            ),
            const SizedBox(width: 16.0),
            // Title and Subtitle column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // Trailing arrow icon
            const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
