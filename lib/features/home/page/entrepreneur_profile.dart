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
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class EntrepreneurProfileView extends StatefulWidget {
  const EntrepreneurProfileView({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<EntrepreneurProfileView> createState() =>
      _EntrepreneurProfileViewState();
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
      child: Builder(
        builder: (profileContext) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F9FB),
            appBar: CustomAppBar(
              title: 'profile.title'.tr(),
              centerTitle: true,
              actions: isCurrentUser && isEntrepreneurAccount
                  ? [
                      IconButton(
                        onPressed: () async {
                          await CustomNavigator.push(Routes.editProfile);
                          if (!profileContext.mounted) return;
                          profileContext.read<HomeBloc>().add(
                                EntrepreneurProfileEvent(
                                    arguments: entrepreneurId),
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
                    child:
                        CircularProgressIndicator(color: Styles.PRIMARY_COLOR),
                  );
                }

                if (state is Error) {
                  return Center(child: Text('profile.load_failed'.tr()));
                }

                if (state is! Done ||
                    state.model is! EntrepreneurProfileModel) {
                  return const SizedBox.shrink();
                }

                final model = state.model as EntrepreneurProfileModel;

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
                                  Tab(text: 'profile.projects_status'.tr()),
                                  Tab(text: 'profile.reviews'.tr()),
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
                        _EntrepreneurReviewsTab(model: model),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((model.bio ?? '').trim().isNotEmpty) ...[
              Text(
                model.bio!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Styles.SUBTITLE,
                ),
              ),
              SizedBox(height: 14.h),
              const Divider(),
            ],
            _EntrepreneurInfoRow(
              label: 'profile.job_title'.tr(),
              value: model.jobTitle,
            ),
            _EntrepreneurInfoRow(
              label: 'profile.account_type'.tr(),
              value: 'settings_screen.account_type_entrepreneur'.tr(),
            ),
            _EntrepreneurInfoRow(
              label: 'profile.total_projects'.tr(),
              value: model.totalProjects.toString(),
            ),
            _EntrepreneurInfoRow(
              label: 'profile.reviews_count'.tr(),
              value: model.reviews.length.toString(),
            ),
            _EntrepreneurInfoRow(
              label: 'profile.average_rating'.tr(),
              value: model.averageRating.toStringAsFixed(1),
            ),
            _EntrepreneurInfoRow(
              label: 'profile.identity_verified'.tr(),
              value: model.identityAuthenticated
                  ? 'profile.verified'.tr()
                  : 'profile.not_verified'.tr(),
              valueColor: model.identityAuthenticated
                  ? const Color(0xFF0E9F6E)
                  : Styles.IN_ACTIVE,
            ),
            _EntrepreneurInfoRow(
              label: 'profile.bank_account'.tr(),
              value: model.bankAccountAdded
                  ? 'profile.verified'.tr()
                  : 'profile.not_verified'.tr(),
              valueColor: model.bankAccountAdded
                  ? const Color(0xFF0E9F6E)
                  : Styles.IN_ACTIVE,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntrepreneurInfoRow extends StatelessWidget {
  const _EntrepreneurInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String? value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Styles.HEADER,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              (value ?? '').trim().isEmpty ? '-' : value!,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Styles.SUBTITLE,
              ),
            ),
          ),
        ],
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

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Styles.PRIMARY_COLOR,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_copy_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      'profile.total_projects'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    model.totalProjects.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final project = model.projects[index];
                final presentation = _projectStatusPresentation(project.status);

                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: presentation.color.withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: presentation.color.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          presentation.icon,
                          color: presentation.color,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (project.count ?? 0).toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Styles.HEADER,
                              ),
                            ),
                            Text(
                              presentation.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: Styles.SUBTITLE,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: model.projects.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        ],
      ),
    );
  }

  _ProjectStatusPresentation _projectStatusPresentation(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();

    if (normalized == 'مسودة' || normalized == 'draft') {
      return _ProjectStatusPresentation(
        label: 'project_status.draft'.tr(),
        icon: Icons.edit_note_outlined,
        color: const Color(0xFF64748B),
      );
    }
    if (normalized == 'قيد المراجعة' || normalized == 'under review') {
      return _ProjectStatusPresentation(
        label: 'project_status.under_review'.tr(),
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFD97706),
      );
    }
    if (normalized == 'مفتوحة' || normalized == 'open') {
      return _ProjectStatusPresentation(
        label: 'project_status.open'.tr(),
        icon: Icons.lock_open_outlined,
        color: const Color(0xFF0E9F6E),
      );
    }
    if (normalized == 'قيد التنفيذ' || normalized == 'in progress') {
      return _ProjectStatusPresentation(
        label: 'project_status.in_progress'.tr(),
        icon: Icons.pending_actions_outlined,
        color: const Color(0xFF2563EB),
      );
    }
    if (normalized == 'مكتملة' || normalized == 'completed') {
      return _ProjectStatusPresentation(
        label: 'project_status.completed'.tr(),
        icon: Icons.task_alt_outlined,
        color: const Color(0xFF059669),
      );
    }
    if (normalized == 'مغلقة' || normalized == 'closed') {
      return _ProjectStatusPresentation(
        label: 'project_status.closed'.tr(),
        icon: Icons.lock_outline,
        color: const Color(0xFF475569),
      );
    }
    if (normalized == 'ملغاة' || normalized == 'canceled') {
      return _ProjectStatusPresentation(
        label: 'project_status.canceled'.tr(),
        icon: Icons.cancel_outlined,
        color: const Color(0xFFDC2626),
      );
    }
    if (normalized == 'مرفوض' ||
        normalized == 'مرفوضة' ||
        normalized == 'rejected') {
      return _ProjectStatusPresentation(
        label: 'project_status.rejected'.tr(),
        icon: Icons.block_outlined,
        color: const Color(0xFFB91C1C),
      );
    }

    return _ProjectStatusPresentation(
      label: normalized.isEmpty ? 'profile.projects_status'.tr() : status!,
      icon: Icons.work_outline,
      color: Styles.PRIMARY_COLOR,
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
        child: Text('profile.no_reviews'.tr()),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: model.reviews.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _EntrepreneurReviewCard(review: model.reviews[index]);
      },
    );
  }
}

class _EntrepreneurReviewCard extends StatelessWidget {
  const _EntrepreneurReviewCard({
    required this.review,
  });

  final EntrepreneurReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Styles.BORDER_COLOR),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
                        (index) => Icon(
                          index < review.rating.round()
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

class _ProjectStatusPresentation {
  const _ProjectStatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
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
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
