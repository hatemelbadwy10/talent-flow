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
import 'package:talent_flow/features/home/model/entrepreneur_profile_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class EntrepreneurProfileView extends StatelessWidget {
  const EntrepreneurProfileView({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    final prefs = sl<SharedPreferences>();
    final currentUserId =
        int.tryParse(prefs.getString(AppStorageKey.userId) ?? '');
    final entrepreneurId =
        arguments?['entrepreneurId'] as int? ?? currentUserId;
    final isCurrentUser =
        entrepreneurId != null && entrepreneurId == currentUserId;
    final isEntrepreneurAccount =
        !(prefs.getBool(AppStorageKey.isFreelancer) ?? false);

    if (entrepreneurId == null) {
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
      create: (_) => HomeBloc(homeRepo: sl())
        ..add(EntrepreneurProfileRequested(entrepreneurId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: isCurrentUser && isEntrepreneurAccount
              ? [
                  IconButton(
                    onPressed: () {
                      CustomNavigator.push(Routes.editProfile);
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
            if (state is EntrepreneurProfileLoaded) {
              final EntrepreneurProfileModel model = state.profile;
              return DefaultTabController(
                length: 2,
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
                      _EntrepreneurProjectsTab(model: model),
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

class _EntrepreneurHero extends StatelessWidget {
  const _EntrepreneurHero({
    required this.model,
  });

  final EntrepreneurProfileModel model;

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
                    _InfoPill(
                      text: 'settings_screen.account_type_entrepreneur'.tr(),
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
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'profile.total_projects'.tr(),
                  value: '${model.totalProjects}',
                  icon: Icons.folder_open_outlined,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'profile.projects_status'.tr(),
                  value: '${model.projects.length}',
                  icon: Icons.stacked_bar_chart_outlined,
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

class _EntrepreneurAboutTab extends StatelessWidget {
  const _EntrepreneurAboutTab({
    required this.model,
  });

  final EntrepreneurProfileModel model;

  @override
  Widget build(BuildContext context) {
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
    if (model.projects.isEmpty) {
      return Center(
        child: Text('profile.no_projects'.tr()),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemCount: model.projects.length,
      itemBuilder: (context, index) {
        final item = model.projects[index];
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.folder_copy_outlined,
                  color: Styles.PRIMARY_COLOR,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                '${item.count ?? 0}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Styles.HEADER,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _localizeProjectStatus(context, item.status),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
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
                  maxLines: 2,
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

String _localizeProjectStatus(BuildContext context, String? status) {
  final raw = (status ?? '').trim();
  if (raw.isEmpty) {
    return '-';
  }

  const map = {
    'draft': 'project_status.draft',
    'completed': 'project_status.completed',
    'rejected': 'project_status.rejected',
    'canceled': 'project_status.canceled',
    'cancelled': 'project_status.canceled',
    'open': 'project_status.open',
    'in_progress': 'project_status.in_progress',
    'under_review': 'project_status.under_review',
    'closed': 'project_status.closed',
    'مسودة': 'project_status.draft',
    'مكتملة': 'project_status.completed',
    'مرفوض': 'project_status.rejected',
    'مرفوضة': 'project_status.rejected',
    'ملغاة': 'project_status.canceled',
    'مفتوحة': 'project_status.open',
    'مفتوح': 'project_status.open',
    'قيد التنفيذ': 'project_status.in_progress',
    'قيد المراجعة': 'project_status.under_review',
    'مغلقة': 'project_status.closed',
  };

  final key = map[raw] ?? map[raw.toLowerCase()];
  return key != null ? key.tr() : raw;
}
