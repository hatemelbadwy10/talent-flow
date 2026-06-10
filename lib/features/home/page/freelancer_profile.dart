import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/skills_section.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import 'package:easy_localization/easy_localization.dart';
import '../model/freelancer_profile_model.dart';
import '../widgets/freelancer_work_card.dart';

class FreelancerProfileView extends StatelessWidget {
  final Map<String, dynamic> arguments;
  const FreelancerProfileView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(homeRepo: sl())
        ..add(
          FreelancerProfile(arguments: arguments["freelancerId"]),
        ),
      child: Scaffold(
        backgroundColor: Styles.BACKGROUND_COLOR,
        appBar: CustomAppBar(title: "freelancer_profile".tr()),
        body: BlocBuilder<HomeBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            } else if (state is Error) {
              return Center(child: Text("profile.load_failed".tr()));
            } else if (state is Done) {
              final model = state.model as FreelancerProfileModel;

              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F4F8),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.all(24.w),
                      child: _FreelancerHeader(model: model),
                    ),

                    // TabBar
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: Styles.PRIMARY_COLOR,
                        unselectedLabelColor: Styles.SUBTITLE,
                        indicatorColor: Styles.PRIMARY_COLOR,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: "bio".tr()),
                          Tab(text: "reviews".tr()),
                          Tab(text: "works".tr()),
                        ],
                      ),
                    ),

                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        children: [
                          _BioTab(model: model),
                          _ReviewsTab(model: model),
                          _WorksTab(model: model),
                        ],
                      ),
                    ),
                  ],
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

class _FreelancerHeader extends StatelessWidget {
  final FreelancerProfileModel model;
  const _FreelancerHeader({required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 50.w,
          backgroundColor: Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
          backgroundImage:
              model.image != null ? NetworkImage(model.image!) : null,
          child: model.image == null
              ? Icon(Icons.person, size: 50.w, color: Styles.PRIMARY_COLOR)
              : null,
        ),

        SizedBox(height: 16.h),

        // Name and Online Status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                model.name ?? "no_name".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Styles.HEADER,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // Job Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline,
                color: Styles.PRIMARY_COLOR, size: 16),
            SizedBox(width: 8.w),
            Text(model.jobTitle ?? "no_job_title".tr()),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _StatusBadge(
                label: 'profile.identity_verified'.tr(),
                value: model.identityAuthenticated,
                icon: Icons.verified_user_outlined,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatusBadge(
                label: 'profile.bank_account'.tr(),
                value: model.bankAccountAdded,
                icon: Icons.account_balance_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final bool value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = value ? const Color(0xFF0E9F6E) : Styles.IN_ACTIVE;
    final statusIcon = value ? Icons.check_rounded : Icons.close_rounded;

    return Container(
      constraints: BoxConstraints(minHeight: 58.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                PositionedDirectional(
                  end: 3.w,
                  bottom: 3.w,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.4),
                    ),
                    child: Icon(statusIcon, size: 8, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: Color(0xFF20313A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bio Tab
class _BioTab extends StatelessWidget {
  final FreelancerProfileModel model;
  const _BioTab({required this.model});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: Colors.grey.shade200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.bio != null && model.bio!.isNotEmpty) ...[
              Text("bio".tr()),
              Divider(color: Colors.grey.shade400, thickness: .5),
              SizedBox(height: 12.h),
              Text(model.bio!),
              SizedBox(height: 24.h),
            ],
            Divider(color: Colors.grey.shade400, thickness: .5),
            if (model.skills.isNotEmpty) ...[
              SkillsSection(skills: model.skills),
            ],
            if ((model.bio == null || model.bio!.isEmpty) &&
                model.skills.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.h),
                  child: Text("no_info_available".tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Reviews Tab
class _ReviewsTab extends StatelessWidget {
  final FreelancerProfileModel model;
  const _ReviewsTab({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Text("no_reviews".tr()),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: model.reviews.length,
      itemBuilder: (context, index) {
        final review = model.reviews[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Styles.BORDER_COLOR),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFF3F4F6),
                    backgroundImage: (review.image ?? '').trim().isNotEmpty
                        ? NetworkImage(review.image!)
                        : null,
                    child: (review.image ?? '').trim().isEmpty
                        ? const Icon(Icons.person, color: Color(0xFF6B7280))
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (review.name ?? '').trim().isNotEmpty
                              ? review.name!
                              : '-',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Styles.HEADER,
                          ),
                        ),
                        if ((review.jobTitle ?? '').trim().isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            review.jobTitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Styles.HINT_COLOR,
                            ),
                          ),
                        ],
                        SizedBox(height: 8.h),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < review.rating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 18,
                              color: const Color(0xFFFFB800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    (review.date ?? '').trim().isNotEmpty ? review.date! : '-',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Styles.HINT_COLOR,
                    ),
                  ),
                ],
              ),
              if ((review.comment ?? '').trim().isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  review.comment!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Styles.SUBTITLE,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Works Tab
class _WorksTab extends StatelessWidget {
  final FreelancerProfileModel model;
  const _WorksTab({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.works.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Text("no_works".tr()),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 200 / 320,
        ),
        itemCount: model.works.length,
        itemBuilder: (context, index) {
          return FreelancerWorkCard(work: model.works[index]);
        },
      ),
    );
  }
}
