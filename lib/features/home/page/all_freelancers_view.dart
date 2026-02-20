import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/images.dart';
import '../../../data/config/di.dart';
import '../../setting/widgets/setting_app_bar.dart';
import '../bloc/home_bloc.dart';
import '../model/freelancers_model.dart';
import '../model/home_model.dart' hide Card;
import '../widgets/freelancer_listview_item.dart';

class AllFreelancersView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const AllFreelancersView({super.key, this.arguments});

  @override
  State<AllFreelancersView> createState() => _AllFreelancersViewState();
}

class _AllFreelancersViewState extends State<AllFreelancersView> {
  Category? _selectedCategory;

  late HomeBloc _categoriesBloc;
  late HomeBloc _freelancersBloc;

  @override
  void initState() {
    super.initState();
    _categoriesBloc = HomeBloc(homeRepo: sl());
    _freelancersBloc = HomeBloc(homeRepo: sl());

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
    _categoriesBloc.close();
    _freelancersBloc.close();
    super.dispose();
  }

  void _selectCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _applyFilters() {
    if (_selectedCategory == null) {
      _freelancersBloc.add(Follow());
    } else {
      _freelancersBloc.add(Follow(arguments: _selectedCategory!.id));
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              expand: false,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "filter".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  _selectedCategory = null;
                                });
                                setState(() {
                                  _selectedCategory = null;
                                });
                                _applyFilters();
                              },
                              child: Text(
                                "clear_all".tr(),
                                style:const TextStyle(
                                  color: Styles.PRIMARY_COLOR,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[300], height: 1),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "specialization".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Expanded(
                                child: BlocBuilder<HomeBloc, AppState>(
                                  bloc: _categoriesBloc,
                                  builder: (context, state) {
                                    if (state is Loading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (state is Error) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              "loading_failed".tr(),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            TextButton(
                                              onPressed: () => _categoriesBloc.add(Click()),
                                              child: Text("retry".tr()),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (state is Done) {
                                      final categories = state.list as List<Category>;

                                      if (categories.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "no_categories".tr(),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView(
                                        controller: controller,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 8.h),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _selectedCategory == null
                                                    ? Styles.PRIMARY_COLOR
                                                    : Colors.grey[300]!,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 4.h,
                                              ),
                                              title: Text(
                                                "all_categories".tr(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: _selectedCategory == null
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: _selectedCategory == null
                                                      ? Styles.PRIMARY_COLOR
                                                      : Colors.black87,
                                                ),
                                              ),
                                              trailing: _selectedCategory == null
                                                  ?const Icon(
                                                Icons.check_circle,
                                                color: Styles.PRIMARY_COLOR,
                                                size: 20,
                                              )
                                                  : null,
                                              onTap: () {
                                                setModalState(() {
                                                  _selectedCategory = null;
                                                });
                                                setState(() {
                                                  _selectedCategory = null;
                                                });
                                                _applyFilters();
                                              },
                                            ),
                                          ),
                                          ...categories.map((category) {
                                            final isSelected = _selectedCategory?.id == category.id;
                                            return Container(
                                              margin: EdgeInsets.only(bottom: 8.h),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Styles.PRIMARY_COLOR
                                                      : Colors.grey[300]!,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 4.h,
                                                ),
                                                title: Text(
                                                  category.name ?? "no_name".tr(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                    color: isSelected
                                                        ? Styles.PRIMARY_COLOR
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                trailing: isSelected
                                                    ?const Icon(
                                                  Icons.check_circle,
                                                  color: Styles.PRIMARY_COLOR,
                                                  size: 20,
                                                )
                                                    : null,
                                                onTap: () {
                                                  setModalState(() {
                                                    _selectedCategory = category;
                                                  });
                                                  setState(() {
                                                    _selectedCategory = category;
                                                  });
                                                  _applyFilters();
                                                },
                                              ),
                                            );
                                          }),
                                        ],
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
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.PRIMARY_COLOR,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "apply_filter".tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: _categoriesBloc),
        BlocProvider<HomeBloc>.value(value: _freelancersBloc),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: "freelancers2".tr(),
          actions: [
            if (widget.arguments?["categoryId"] == null)
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.tune, color: Colors.black87),
                    if (_selectedCategory != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Styles.PRIMARY_COLOR,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_selectedCategory != null)
              Container(
                width: double.infinity,
                color: Colors.blue[50],
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt,
                      size: 18,
                      color: Styles.PRIMARY_COLOR,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "filter_applied".tr(
                        namedArgs: {"category": _selectedCategory!.name ?? ""},
                      ),
                      style:const TextStyle(
                        color: Styles.PRIMARY_COLOR,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _selectCategory(null),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BlocBuilder<HomeBloc, AppState>(
                bloc: _freelancersBloc,
                builder: (context, state) {
                  if (state is Loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is Error) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "freelancers_failed".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "check_connection".tr(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () {
                                final categoryId = widget.arguments?["categoryId"] as int?;
                                _freelancersBloc.add(Follow(arguments: categoryId));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.PRIMARY_COLOR,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text("retry".tr()),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is Done) {
                    final freelancers = state.list as List<FreelancersModel>;
                    if (freelancers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Images.emptyOrders, height: 120),
                              SizedBox(height: 24.h),
                              Text(
                                "no_freelancers".tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                _selectedCategory != null
                                    ? "no_freelancers_in_category".tr()
                                    : "no_freelancers_general".tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 1000
                            ? 4
                            : constraints.maxWidth >= 700
                                ? 3
                                : 2;
                        return GridView.builder(
                          padding: EdgeInsets.all(16.w),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 167/220,
                          ),
                          itemCount: freelancers.length,
                          itemBuilder: (context, index) {
                            final freelancer = freelancers[index];
                            final jobTitle = freelancer.jobTitle?.trim() ?? '';
                            return FreelancerListItem(
                              id: freelancer.id ?? 0,
                              name: freelancer.name ?? "no_name".tr(),
                              jopTitle: jobTitle.isNotEmpty
                                  ? jobTitle
                                  : "home.job_title_not_set".tr(),
                              rating: freelancer.rating?.toDouble(),
                              imageUrl: freelancer.image,
                              cardWidth: double.infinity,
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
