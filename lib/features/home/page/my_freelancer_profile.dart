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
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/main_models/user_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../model/freelancer_profile_model.dart';

class MyFreelancerProfileView extends StatefulWidget {
  const MyFreelancerProfileView({super.key});

  @override
  State<MyFreelancerProfileView> createState() =>
      _MyFreelancerProfileViewState();
}

class _MyFreelancerProfileViewState extends State<MyFreelancerProfileView> {
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
          HomeBloc(homeRepo: sl())..add(FreelancerProfile(arguments: userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await CustomNavigator.push(Routes.editProfile);
                // Profile will update automatically via UserBloc
              },
              icon: const Icon(
                Icons.edit_outlined,
                color: Styles.PRIMARY_COLOR,
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<UserBloc, AppState>(
          builder: (context, state) {
            final userBloc = context.read<UserBloc>();
            final user = userBloc.user;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }

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
                              child: _ProfileHero(user: user),
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
                          _AboutTab(user: user),
                          BlocBuilder<HomeBloc, AppState>(
                            builder: (context, homeState) {
                              if (homeState is Done &&
                                  homeState.model is FreelancerProfileModel) {
                                return _ReviewsTab(
                                  model:
                                      homeState.model as FreelancerProfileModel,
                                );
                              }
                              if (homeState is Error) {
                                return Center(
                                  child: Text('profile.load_failed'.tr()),
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Styles.PRIMARY_COLOR,
                                ),
                              );
                            },
                          ),
                          BlocBuilder<HomeBloc, AppState>(
                            builder: (context, homeState) {
                              if (homeState is Done &&
                                  homeState.model is FreelancerProfileModel) {
                                return _WorksTab(
                                  model:
                                      homeState.model as FreelancerProfileModel,
                                );
                              }
                              if (homeState is Error) {
                                return Center(
                                  child: Text('profile.load_failed'.tr()),
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Styles.PRIMARY_COLOR,
                                ),
                              );
                            },
                          ),
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
    required this.user,
  });

  final UserModel user;

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
                  child: (user.profileImage ?? '').trim().isNotEmpty
                      ? Image.network(
                          user.profileImage!,
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
                      user.name ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    if ((user.jobTitle ?? '').trim().isNotEmpty)
                      Text(
                        user.jobTitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    if ((user.specialization ?? '').trim().isNotEmpty)
                      _InfoPill(text: user.specialization!),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          if ((user.bio ?? '').trim().isNotEmpty)
            Text(
              user.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.92),
              ),
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
    required this.user,
  });

  final UserModel user;

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
              (user.bio ?? '').trim().isEmpty
                  ? 'no_info_available'.tr()
                  : user.bio!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Styles.SUBTITLE,
              ),
            ),
          ),
          if ((user.specialization ?? '').trim().isNotEmpty) ...[
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.specialization'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    user.specialization!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Styles.SUBTITLE,
                    ),
                  ),
                ],
              ),
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
                    context
                        .read<HomeBloc>()
                        .add(FreelancerProfile(arguments: model.id));
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
  });

  final FreelancerReview review;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
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
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            index < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 18,
                            color: const Color(0xFFFFB800),
                          ),
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
            SizedBox(height: 14.h),
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
