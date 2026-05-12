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
import 'package:talent_flow/main_models/user_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class EntrepreneurProfileView extends StatefulWidget {
  const EntrepreneurProfileView({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<EntrepreneurProfileView> createState() => _EntrepreneurProfileViewState();
}

class _EntrepreneurProfileViewState extends State<EntrepreneurProfileView> {

  @override
  Widget build(BuildContext context) {
    final prefs = sl<SharedPreferences>();
    final currentUserId =
        int.tryParse(prefs.getString(AppStorageKey.userId) ?? '');
    final entrepreneurId =
        widget.arguments?['entrepreneurId'] as int? ?? currentUserId;
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
        ..add(EntrepreneurProfileEvent(arguments: entrepreneurId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: CustomAppBar(
          title: 'profile.title'.tr(),
          centerTitle: true,
          actions: isCurrentUser && isEntrepreneurAccount
              ? [
                  IconButton(
                    onPressed: () async {
                      await CustomNavigator.push(Routes.editProfile);
                      // Refresh profile data on return
                      if (mounted) {
                        context.read<HomeBloc>().add(
                          EntrepreneurProfileEvent(arguments: entrepreneurId),
                        );
                      }
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
            final userBloc = context.read<UserBloc>();
            final user = userBloc.user;
            
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
              );
            }
            
            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                        child: _EntrepreneurHero(user: user),
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
                    _EntrepreneurAboutTab(user: user),
                    _EntrepreneurProjectsTab(user: user),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EntrepreneurHero extends StatelessWidget {
  const _EntrepreneurHero({
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
                    Text(
                      (user.jobTitle ?? '').trim().isNotEmpty
                          ? user.jobTitle!
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
            (user.bio ?? '').trim().isEmpty
                ? 'no_info_available'.tr()
                : user.bio!,
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
    required this.user,
  });

  final UserModel user;

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
    );
  }
}

class _EntrepreneurProjectsTab extends StatelessWidget {
  const _EntrepreneurProjectsTab({
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('profile.no_projects'.tr()),
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
