import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/images.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart' show sl;
import '../bloc/my_projects_bloc.dart';
import '../model/my_projects_model.dart';
import '../repo/projects_repo.dart';
import '../widgets/my_projects_card.dart';

class OwnerProjects extends StatelessWidget {
  final Map<String, dynamic>? arguments;
  const OwnerProjects({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final categoryId = arguments?['categoryId'] as int?;
    log('categoryId $categoryId');
    return BlocProvider(
      create: (context) =>
      MyProjectsBloc(sl())..add(Add(arguments: categoryId)),
      child: _OwnerProjectsContent(categoryId: categoryId),
    );
  }
}

class _OwnerProjectsContent extends StatefulWidget {
  final int? categoryId;
  const _OwnerProjectsContent({this.categoryId});

  @override
  State<_OwnerProjectsContent> createState() => _OwnerProjectsContentState();
}

class _OwnerProjectsContentState extends State<_OwnerProjectsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String?, String> statuses = {
    null: "الكل",
    "completed": "project_status.completed".tr(),
    "draft": "project_status.draft".tr(),
    "rejected": "project_status.rejected".tr(),
    "canceled": "project_status.canceled".tr(),
    "open": "project_status.open".tr(),
    "in_progress": "project_status.in_progress".tr(),
    "under_review": "project_status.under_review".tr(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.categoryId == null) {
      _tabController = TabController(length: statuses.length, vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.categoryId == null) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 200;
    const double cardHeight = 320;
    const double aspectRatio = cardWidth / cardHeight;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: Text('owner_projects.my_projects'.tr()),

          /// 👇 فقط لو مفيش categoryId
          bottom: widget.categoryId == null
              ? TabBar(
            controller: _tabController,
            isScrollable: true,
            onTap: (index) {
              final status = statuses.keys.elementAt(index);
              context
                  .read<MyProjectsBloc>()
                  .add(Add(arguments: status));
            },
            tabs:
            statuses.values.map((label) => Tab(text: label)).toList(),
          )
              : null,
        ),
        body: BlocBuilder<MyProjectsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is Error) {
              return Center(child: Text("error.loading".tr()));
            } else if (state is Done) {
              final projects = state.list?.cast<MyProjectsModel>();
              if (projects != null && projects.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(
                      right: 16, left: 16, top: 8, bottom: 32),
                  child: GridView.builder(
                    itemCount: projects.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectPortfolioCard(
                        projectsModel: project,
                      );
                    },
                  ),
                );
              } else {
                return Center(child: Image.asset(Images.emptyOrders));
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
