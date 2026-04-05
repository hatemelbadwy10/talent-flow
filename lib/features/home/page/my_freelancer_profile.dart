import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/bloc/home_event.dart';
import 'package:talent_flow/features/home/bloc/home_state.dart';
import 'package:talent_flow/features/home/model/freelancer_profile_model.dart';
import 'package:talent_flow/features/home/widgets/freelancer_work_card.dart';
import 'package:talent_flow/features/new_projects/widgets/skills_section.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class MyFreelancerProfileView extends StatelessWidget {
  const MyFreelancerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = int.tryParse(
        sl<SharedPreferences>().getString(AppStorageKey.userId) ?? '');

    if (userId == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
        ),
        body: Center(
          child: Text('profile.load_failed'.tr()),
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          HomeBloc(homeRepo: sl())..add(FreelancerProfileRequested(userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                CustomNavigator.push(Routes.editProfile);
              },
              icon:
                  const Icon(Icons.edit_outlined, color: Styles.PRIMARY_COLOR),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }
            if (state is HomeFailure) {
              return Center(child: Text('profile.load_failed'.tr()));
            }
            if (state is FreelancerProfileLoaded) {
              final FreelancerProfileModel model = state.profile;
              return DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                                child: _ProfileHero(model: model),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TabBar(
                                    labelColor: Styles.PRIMARY_COLOR,
                                    unselectedLabelColor: Styles.HINT_COLOR,
                                    indicatorColor: Styles.PRIMARY_COLOR,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    tabs: [
                                      Tab(text: 'profile.about_me'.tr()),
                                      Tab(text: 'profile.reviews'.tr()),
                                      Tab(text: 'profile.works'.tr()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                          children: [
                            _AboutTab(model: model),
                            _ReviewsTab(model: model),
                            _WorksTab(model: model),
                          ],
                        ),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.model,
  });

  final FreelancerProfileModel model;

  @override
  Widget build(BuildContext context) {
    final statistics = model.statistics;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E8A8F),
            Color(0xFF0A6E72),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: model.image != null && model.image!.trim().isNotEmpty
                      ? Image.network(
                          model.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    if ((model.jobTitle ?? '').trim().isNotEmpty)
                      Text(
                        model.jobTitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((model.specialization ?? '').trim().isNotEmpty)
                          _InfoPill(text: model.specialization!),
                        if ((model.country?.toString().trim().isNotEmpty ??
                            false))
                          _InfoPill(text: model.country.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          if ((model.bio ?? '').trim().isNotEmpty)
            Text(
              model.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'project_portfolio.views'.tr(),
                  value: statistics?.registrationDate ?? '-',
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'profile.works'.tr(),
                  value: '${model.works.length}',
                  icon: Icons.work_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: Colors.white.withValues(alpha: 0.16),
      child: const Icon(Icons.person, color: Colors.white, size: 34),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.model,
  });

  final FreelancerProfileModel model;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              (model.bio ?? '').trim().isEmpty
                  ? 'no_info_available'.tr()
                  : model.bio!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Styles.SUBTITLE,
              ),
            ),
          ),
          if (model.skills.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SkillsSection(skills: model.skills),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({
    required this.model,
  });

  final FreelancerProfileModel model;

  @override
  Widget build(BuildContext context) {
    if (model.reviews.isEmpty) {
      return Center(
        child: Text('profile.no_reviews'.tr()),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: model.reviews.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final review = model.reviews[index];
        return Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            review.toString(),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Styles.SUBTITLE,
            ),
          ),
        );
      },
    );
  }
}

class _WorksTab extends StatelessWidget {
  const _WorksTab({
    required this.model,
  });

  final FreelancerProfileModel model;

  @override
  Widget build(BuildContext context) {
    if (model.works.isEmpty) {
      return Center(
        child: Text('profile.no_works'.tr()),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: model.works.length,
      itemBuilder: (context, index) {
        final work = model.works[index];
        return FreelancerWorkCard(
          work: work,
          onTap: work.id == null
              ? null
              : () async {
                  final shouldRefresh = await CustomNavigator.push(
                    Routes.work,
                    arguments: {
                      'id': work.id,
                      'work': work,
                      'canEdit': true,
                    },
                  );
                  if (shouldRefresh == true &&
                      context.mounted &&
                      model.id != null) {
                    context
                        .read<HomeBloc>()
                        .add(FreelancerProfileRequested(model.id!));
                  }
                },
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
