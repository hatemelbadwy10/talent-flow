import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import '../bloc/home_bloc.dart';
import '../model/freelancers_model.dart';
import '../model/home_model.dart' hide Card;
import '../widgets/freelancer_details_item.dart';

class AllFreelancersView extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const AllFreelancersView({super.key, this.arguments});

  @override
  State<AllFreelancersView> createState() => _AllFreelancersViewState();
}

class _AllFreelancersViewState extends State<AllFreelancersView> {
  List<Category> _categories = [];
  final List<String> _selectedCategories = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  late HomeBloc _categoriesBloc;
  late HomeBloc _freelancersBloc;

  @override
  void initState() {
    super.initState();
    _categoriesBloc = HomeBloc(homeRepo: sl());
    _freelancersBloc = HomeBloc(homeRepo: sl());

    // ✅ check arguments
    final categoryId = widget.arguments?["categoryId"] as int?;
    if (categoryId != null) {
      _freelancersBloc.add(Follow(arguments: categoryId));
    } else {
      _categoriesBloc.add(Click());
      _freelancersBloc.add(Follow());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _jobTitleController.dispose();
    _categoriesBloc.close();
    _freelancersBloc.close();
    super.dispose();
  }

  void _toggleCategory(Category category) {
    setState(() {
      if (_selectedCategories.contains(category.name)) {
        _selectedCategories.remove(category.name);
        _freelancersBloc.add(Follow());
      } else {
        _freelancersBloc.add(Follow(arguments: category.id));
        _selectedCategories.add(category.name!);
      }
    });
    _applyFilters();
  }

  void _applyFilters() {
    // هتعمل هنا logic بتاعك لو عايز تبعت فلترة للبلوك
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: _categoriesBloc),
        BlocProvider<HomeBloc>.value(value: _freelancersBloc),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("freelancers.title".tr()),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            // ✅ لو مفيش categoryId اعرض الفلتر
            if (widget.arguments?["categoryId"] == null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    "freelancers.filters".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  iconColor: Styles.PRIMARY_COLOR,
                  childrenPadding: EdgeInsets.all(16.w),
                  children: [
                    Text("freelancers.search_freelancer".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 16.h),
                    Text("freelancers.category".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

                    // 🔹 Dynamic Categories from BLoC
                    BlocBuilder<HomeBloc, AppState>(
                      bloc: _categoriesBloc,
                      builder: (context, state) {
                        if (state is Loading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is Error) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text("فشل تحميل التصنيفات"),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => _categoriesBloc.add(Click()),
                                ),
                              ],
                            ),
                          );
                        } else if (state is Done) {
                          final categories = state.list as List<Category>;
                          _categories = categories; // Store categories for filtering

                          if (categories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("لا توجد تصنيفات متاحة"),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            children: categories.map((category) {
                              final categoryName = category.name ?? "غير محدد";
                              final selected = _selectedCategories.contains(categoryName);
                              return FilterChip(
                                label: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.black,
                                  ),
                                ),
                                selected: selected,
                                selectedColor: Styles.PRIMARY_COLOR,
                                backgroundColor: Colors.grey[200],
                                onSelected: (_) => _toggleCategory(category),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 16.h),
                    Text("freelancers.job_title".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),

            SizedBox(height: 16.h),

            // 🔹 Freelancers List from Bloc
            BlocBuilder<HomeBloc, AppState>(
              bloc: _freelancersBloc,
              builder: (context, state) {
                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is Error) {
                  return Center(
                    child: Column(
                      children: [
                        const Text("فشل تحميل الفريلانسرز"),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            final categoryId = widget.arguments?["categoryId"] as int?;
                            _freelancersBloc.add(Follow(arguments: categoryId));
                          },
                          child: const Text("إعادة المحاولة"),
                        ),
                      ],
                    ),
                  );
                } else if (state is Done) {
                  final freelancers = state.list as List<FreelancersModel>;

                  if (freelancers.isEmpty) {
                    return const Center(child: Text("لا يوجد فريلانسرز حالياً"));
                  }

                  return Column(
                    children: freelancers.map((freelancer) {
                      return GestureDetector(
                        onTap: () {
                          CustomNavigator.push(Routes.freeLancerView,arguments: {"freelancerId": freelancer.id});
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: FreelancerListDetailItem(
                              name: freelancer.name ?? "بدون اسم",
                              title: freelancer.jobTitle ?? "-",
                              rating: freelancer.rating?.toDouble() ?? 0.0,
                              description: freelancer.bio ?? "-",
                              imageUrl: freelancer.image,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
