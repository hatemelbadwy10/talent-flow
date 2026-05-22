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
import 'package:talent_flow/features/home/model/entrepreneur_profile_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/main_models/user_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class EntrepreneurProfileView extends StatefulWidget {
  const EntrepreneurProfileView({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<EntrepreneurProfileView> createState() => _EntrepreneurProfileViewState();
}

class _EntrepreneurProfileViewState extends State<EntrepreneurProfileView> {
  late final int? _currentUserId;
  late final int? _entrepreneurId;
  late final bool _isCurrentUser;
  late final bool _isEntrepreneurAccount;
  late final bool _useCurrentProfile;

  @override
  void initState() {
    super.initState();
    final prefs = sl<SharedPreferences>();
    _currentUserId = int.tryParse(prefs.getString(AppStorageKey.userId) ?? '');
    _useCurrentProfile = widget.arguments?['useCurrentProfile'] == true;
    _entrepreneurId = widget.arguments?['entrepreneurId'] as int? ?? _currentUserId;
    _isCurrentUser = _entrepreneurId != null && _entrepreneurId == _currentUserId;
    _isEntrepreneurAccount = !(prefs.getBool(AppStorageKey.isFreelancer) ?? false);

    if (_useCurrentProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<UserBloc>().add(Click());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entrepreneurId == null) {
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

    if (_useCurrentProfile) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: _isCurrentUser && _isEntrepreneurAccount
              ? [
                  IconButton(
                    onPressed: () async {
                      await CustomNavigator.push(Routes.editProfile);
                      if (!context.mounted) return;
                      context.read<UserBloc>().add(Click());
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Styles.PRIMARY_COLOR,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ]
              : null,
        ),
        body: BlocBuilder<UserBloc, AppState>(
          builder: (context, state) {
            final user = context.read<UserBloc>().user;

            if (state is Loading && user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }
            if (user == null) {
              return Center(child: Text('profile.load_failed'.tr()));
            }

            final model = _mapCurrentUserToEntrepreneurProfile(user);
            return _EntrepreneurProfileScaffold(model: model);
          },
        ),
      );
    }

    return BlocProvider(
      create: (_) => HomeBloc(homeRepo: sl())
        ..add(EntrepreneurProfileEvent(arguments: _entrepreneurId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FB),
            appBar: CustomAppBar(
              title: 'profile.title'.tr(),
              centerTitle: true,
              actions: _isCurrentUser && _isEntrepreneurAccount
                  ? [
                      IconButton(
                        onPressed: () async {
                          await CustomNavigator.push(Routes.editProfile);
                          if (!context.mounted) return;
                          context.read<HomeBloc>().add(
                                EntrepreneurProfileEvent(arguments: _entrepreneurId),
                              );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Styles.PRIMARY_COLOR,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ]
                  : null,
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
                if (state is! Done || state.model is! EntrepreneurProfileModel) {
                  return const SizedBox.shrink();
                }

                final model = state.model as EntrepreneurProfileModel;

                return _EntrepreneurProfileScaffold(model: model);
              },
            ),
          );
        },
      ),
    );
  }
}

EntrepreneurProfileModel _mapCurrentUserToEntrepreneurProfile(UserModel user) {
  return EntrepreneurProfileModel.fromJson(
    user.toJson()
      ..putIfAbsent('name', () => user.name)
      ..putIfAbsent('job_title', () => user.jobTitle)
      ..putIfAbsent('image', () => user.profileImage)
      ..putIfAbsent('bio', () => user.bio)
      ..putIfAbsent('projects', () => const []),
  );
}

class _EntrepreneurProfileScaffold extends StatelessWidget {
  const _EntrepreneurProfileScaffold({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: _EntrepreneurHero(model: model),
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
                      Tab(text: 'profile.projects_status'.tr()),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _EntrepreneurAboutTab(model: model),
            _EntrepreneurReviewsTab(model: model),
            _EntrepreneurProjectsTab(model: model),
          ],
        ),
      ),
    );
  }
}

class _EntrepreneurHero extends StatelessWidget {
  const _EntrepreneurHero({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
    final totalReviews = model.noOfReviews > 0
        ? model.noOfReviews
        : model.reviews.length;

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
                      (model.name ?? '').trim().isNotEmpty ? model.name! : '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      (model.jobTitle ?? '').trim().isNotEmpty
                          ? model.jobTitle!
                          : 'settings_screen.account_type_entrepreneur'.tr(),
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
                        _InfoPill(
                          text: 'settings_screen.account_type_entrepreneur'.tr(),
                        ),
                        if (model.rating > 0 || totalReviews > 0)
                          _InfoPill(
                            text:
                                '${model.rating.toStringAsFixed(1)} ★  ($totalReviews)',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            (model.bio ?? '').trim().isEmpty
                ? 'no_info_available'.tr()
                : model.bio!,
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

class _EntrepreneurAboutTab extends StatelessWidget {
  const _EntrepreneurAboutTab({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
    final infoRows = <MapEntry<String, String>>[
      if ((model.specialization ?? '').trim().isNotEmpty)
        MapEntry('Specialization', model.specialization!),
      if ((model.country ?? '').trim().isNotEmpty)
        MapEntry('Country', model.country!),
      if ((model.statistics?.city ?? '').trim().isNotEmpty)
        MapEntry('City', model.statistics!.city!),
      if ((model.statistics?.registrationDate ?? '').trim().isNotEmpty)
        MapEntry('Joined', model.statistics!.registrationDate!),
      if ((model.statistics?.lastSeen ?? '').trim().isNotEmpty)
        MapEntry('Last seen', model.statistics!.lastSeen!),
    ];

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
            Text(
              (model.bio ?? '').trim().isEmpty
                  ? 'no_info_available'.tr()
                  : model.bio!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Styles.SUBTITLE,
              ),
            ),
            if (infoRows.isNotEmpty) ...[
              SizedBox(height: 20.h),
              ...infoRows.map(_ProfileInfoRow.new),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntrepreneurReviewsTab extends StatelessWidget {
  const _EntrepreneurReviewsTab({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
    if (model.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Text('profile.no_reviews'.tr()),
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
                  if ((review.date ?? '').trim().isNotEmpty)
                    Text(
                      review.date!,
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
                    fontSize: 13,
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

class _EntrepreneurProjectsTab extends StatelessWidget {
  const _EntrepreneurProjectsTab({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
    final stats = model.statistics;
    final cards = <_ProjectMetric>[
      if (stats?.openProjectsCount != null)
        _ProjectMetric(
          label: 'Open projects',
          value: stats!.openProjectsCount.toString(),
          icon: Icons.folder_open_outlined,
        ),
      if (stats?.underImplementationCount != null)
        _ProjectMetric(
          label: 'In progress',
          value: stats!.underImplementationCount.toString(),
          icon: Icons.timelapse_outlined,
        ),
      if (stats?.ongoingCommunications != null)
        _ProjectMetric(
          label: 'Communications',
          value: stats!.ongoingCommunications.toString(),
          icon: Icons.forum_outlined,
        ),
      ...model.projects.map(
        (project) => _ProjectMetric(
          label: (project.status ?? '').trim().isNotEmpty
              ? project.status!
              : 'profile.projects_status'.tr(),
          value: (project.count ?? 0).toString(),
          icon: Icons.work_outline,
        ),
      ),
    ];

    if (cards.isEmpty) {
      return Center(
        child: Text('profile.no_projects'.tr()),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(card.icon, color: Styles.PRIMARY_COLOR),
              ),
              Text(
                card.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Styles.HEADER,
                ),
              ),
              Text(
                card.label,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Styles.SUBTITLE,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow(this.entry);

  final MapEntry<String, String> entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Styles.HEADER,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.value,
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

class _ProjectMetric {
  const _ProjectMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
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
