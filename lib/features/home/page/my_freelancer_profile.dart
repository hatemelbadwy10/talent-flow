import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/widgets/freelancer_work_card.dart';
import 'package:talent_flow/features/new_projects/widgets/skills_section.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../model/freelancer_profile_model.dart';

class MyFreelancerProfileView extends StatefulWidget {
  const MyFreelancerProfileView({super.key});

  @override
  State<MyFreelancerProfileView> createState() => _MyFreelancerProfileViewState();
}

class _MyFreelancerProfileViewState extends State<MyFreelancerProfileView> {
  int? get _userId => int.tryParse(
        sl<SharedPreferences>().getString(AppStorageKey.userId) ?? '',
      );

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
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
      create: (_) => HomeBloc(homeRepo: sl())..add(FreelancerProfile(arguments: userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await CustomNavigator.push(Routes.editProfile);
                if (context.mounted) {
                  context.read<HomeBloc>().add(FreelancerProfile(arguments: userId));
                }
              },
              icon: const Icon(
                Icons.edit_outlined,
                color: Styles.PRIMARY_COLOR,
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<HomeBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }
            if (state is Error) {
              return Center(child: Text('profile.load_failed'.tr()));
            }
            if (state is! Done || state.model is! FreelancerProfileModel) {
              return const SizedBox.shrink();
            }

            final model = state.model as FreelancerProfileModel;
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
                              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                              child: _ProfileHero(model: model),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: TabBar(
                                  isScrollable: true,
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
                  child: (model.image ?? '').trim().isNotEmpty
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
                    if ((model.specialization ?? '').trim().isNotEmpty)
                      _InfoPill(text: model.specialization!),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusBadge(
                label: 'profile.identity_verified'.tr(),
                value: model.identityAuthenticated,
              ),
              _StatusBadge(
                label: 'profile.bank_account'.tr(),
                value: model.bankAccountAdded,
              ),
              _StatusBadge(
                label: 'profile.added_works'.tr(),
                value: model.addedWorks,
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
    final hasBio = (model.bio ?? '').trim().isNotEmpty;
    final hasSkills = model.skills.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasBio) ...[
              Text(
                'bio'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Styles.HEADER,
                ),
              ),
              Divider(color: Colors.grey.shade400, thickness: .5),
              SizedBox(height: 12.h),
              Text(
                model.bio!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Styles.SUBTITLE,
                ),
              ),
              SizedBox(height: 24.h),
            ],
            _ProfileInfoRow(
              title: 'profile.country'.tr(),
              value: model.country?.toString(),
            ),
            _ProfileInfoRow(
              title: 'profile.specialization'.tr(),
              value: model.specialization,
            ),
            _ProfileInfoRow(
              title: 'profile.job_title'.tr(),
              value: model.jobTitle,
            ),
            _ProfileInfoRow(
              title: 'profile.city'.tr(),
              value: model.statistics?.city,
            ),
            _ProfileInfoRow(
              title: 'profile.registration_date'.tr(),
              value: model.statistics?.registrationDate,
            ),
            _ProfileInfoRow(
              title: 'profile.last_seen'.tr(),
              value: model.statistics?.lastSeen,
            ),
            _ProfileInfoRow(
              title: 'profile.completed_projects'.tr(),
              value: model.statistics?.completedProjects?.toString(),
            ),
            _ProfileInfoRow(
              title: 'profile.in_progress_projects'.tr(),
              value: model.statistics?.inProgressProjects?.toString(),
            ),
            if (hasSkills) ...[
              Divider(color: Colors.grey.shade400, thickness: .5),
              SizedBox(height: 12.h),
              SkillsSection(skills: model.skills),
            ],
            if (!hasBio && !hasSkills)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text('no_info_available'.tr()),
                ),
              ),
          ],
        ),
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
        return _ReviewCard(review: review);
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
                    context.read<HomeBloc>().add(
                          FreelancerProfile(arguments: model.id),
                        );
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final color = value ? Styles.ACTIVE : Styles.IN_ACTIVE;
    final icon = value ? Icons.check_circle : Icons.cancel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Styles.HEADER,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Styles.SUBTITLE,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
  });

  final FreelancerReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      (review.name ?? '').trim().isNotEmpty ? review.name! : '-',
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
                  ],
                ),
              ),
              Text(
                (review.date ?? '').trim().isNotEmpty ? review.date! : '-',
                style: const TextStyle(
                  fontSize: 11,
                  color: Styles.HINT_COLOR,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
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
  }
}
