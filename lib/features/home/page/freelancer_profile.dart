import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../model/freelancer_profile_model.dart';

class FreelancerProfileView extends StatelessWidget {
final Map<String, dynamic> arguments;
  const FreelancerProfileView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(homeRepo: sl())..add(
        FreelancerProfile(arguments: arguments["freelancerId"]),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الملف الشخصي"),
          backgroundColor: Styles.PRIMARY_COLOR,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<HomeBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is Error) {
              return const Center(child: Text("فشل تحميل الملف الشخصي"));
            } else if (state is Done) {
              final model = state.model as FreelancerProfileModel;

              return DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Profile Header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundImage: model.image != null
                                      ? NetworkImage(model.image!)
                                      : const AssetImage("assets/images/avatar.png")
                                  as ImageProvider,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (model.name != null)
                                        Text(
                                          model.name!,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Styles.PRIMARY_COLOR,
                                          ),
                                        ),
                                      if (model.jobTitle != null)
                                        Text(
                                          model.jobTitle!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (model.statistics?.rating != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 20),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "${model.statistics!.rating}/5",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // ✅ About Me
                            if (model.bio != null && model.bio!.isNotEmpty)
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("نبذة عني",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8.h),
                                      Text(model.bio!,
                                          style: const TextStyle(
                                              fontSize: 14, height: 1.5)),
                                    ],
                                  ),
                                ),
                              ),

                            SizedBox(height: 16.h),

                            // ✅ Skills
                            if (model.skills.isNotEmpty)
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("المهارات",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 12.h),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: model.skills
                                            .map((s) => Chip(
                                          label: Text(s),
                                          backgroundColor: Styles
                                              .PRIMARY_COLOR
                                              .withOpacity(0.1),
                                          labelStyle: const TextStyle(
                                              color:
                                              Styles.PRIMARY_COLOR,
                                              fontWeight:
                                              FontWeight.w500),
                                        ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          tabs: [
                            Tab(text: "الأعمال"),
                            Tab(text: "التقييمات"),
                          ],
                          labelColor: Styles.PRIMARY_COLOR,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Styles.PRIMARY_COLOR,
                        ),
                      ),
                      pinned: true,
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      // ✅ Works Tab
                      model.works.isNotEmpty
                          ? GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: model.works.length,
                        itemBuilder: (context, index) {
                          final work = model.works[index];
                          return GestureDetector  (
                              onTap: (){
                                CustomNavigator.push(Routes.singleProjectDetails,arguments: {"id": work.id});
                              },
                              child: _ProjectCard(work: work));
                        },
                      )
                          : const Center(child: Text("لا توجد أعمال")),

                      // ✅ Reviews Tab
                      model.reviews.isNotEmpty
                          ? ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: model.reviews.length,
                        itemBuilder: (context, index) {
                          final review = model.reviews[index];
                          return _FeedbackCard(feedback: review);
                        },
                      )
                          : const Center(child: Text("لا توجد تقييمات")),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// SliverAppBarDelegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// Project Card
class _ProjectCard extends StatelessWidget {
  final Work work;

  const _ProjectCard({required this.work});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CustomNavigator.push(Routes.singleProjectDetails,arguments: {"id": work.id}),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          children: [
            Expanded(
              child: work.image != null
                  ? Image.network(work.image!, fit: BoxFit.cover, width: double.infinity)
                  : const Icon(Icons.image_not_supported, size: 50),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                work.title ?? "بدون عنوان",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Feedback Card
class _FeedbackCard extends StatelessWidget {
  final dynamic feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedback["rating"] != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 4.w),
                  Text("${feedback["rating"]}/5",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            if (feedback["comment"] != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(feedback["comment"]),
              ),
            if (feedback["date"] != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  feedback["date"],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
