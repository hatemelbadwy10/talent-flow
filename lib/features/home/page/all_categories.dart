import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';
import '../repo/categories_repository.dart';

class ServiceCategoryView extends StatelessWidget {
  final CategoriesRepository repository;
  final bool isFreelancer;

  const ServiceCategoryView({
    super.key,
    required this.repository,
    required this.isFreelancer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesBloc(
        repository: repository,
      )..add(const CategoriesRequested()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'all_categories'.tr()),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoriesFailed) {
              return Center(child: Text('error_loading_categories'.tr()));
            } else if (state case CategoriesLoaded(:final categories)) {
              if (categories.isEmpty) {
                return Center(child: Text('no_categories_found'.tr()));
              }
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ServiceCategoryTile(
                      icon: category.icon ?? '',
                      title: category.name ?? "",
                      subtitle: category.description ?? "",
                      onTap: () {
                        if (isFreelancer) {
                          CustomNavigator.push(Routes.ownerProjects,
                              arguments: {
                                "categoryName": category.name,
                                "categoryId": category.id,
                              });
                        } else {
                          CustomNavigator.push(Routes.freelancers, arguments: {
                            "categoryId": category.id,
                          });
                        }
                      });
                },
              );
            } else {
              return Center(child: Text('no_categories_found'.tr()));
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
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.network(
                icon,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.category_outlined,
                  color: Colors.grey,
                ),
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
