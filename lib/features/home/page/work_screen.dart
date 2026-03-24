import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/status_chip.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/model/work_details_model.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({
    super.key,
    required this.workId,
    this.initialWork,
    this.canEdit = false,
  });

  final int workId;
  final WorkDetailsModel? initialWork;
  final bool canEdit;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  bool _didEdit = false;
  bool _isFavouriteLoading = false;
  late bool _isInFavorites;

  bool get _canFavourite =>
      !(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false);

  @override
  void initState() {
    super.initState();
    _isInFavorites = widget.initialWork?.isInFavorites ?? false;
  }

  Future<void> _openEdit(BuildContext context) async {
    final shouldRefresh =
        await CustomNavigator.push(Routes.editWork, arguments: widget.workId);
    if (shouldRefresh == true && context.mounted) {
      _didEdit = true;
      context.read<HomeBloc>().add(Open(arguments: widget.workId));
    }
  }

  Future<void> _toggleFavourite(BuildContext context) async {
    if (!_canFavourite || _isFavouriteLoading) {
      return;
    }

    final previous = _isInFavorites;
    setState(() {
      _isFavouriteLoading = true;
      _isInFavorites = !_isInFavorites;
    });

    final result = await sl<FavouriteRepo>().toggleWorkFavourite(widget.workId);
    if (!mounted) {
      return;
    }

    result.fold(
      (_) {
        _isInFavorites = previous;
      },
      (_) {
        context.read<HomeBloc>().add(Open(arguments: widget.workId));
      },
    );

    setState(() {
      _isFavouriteLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(homeRepo: sl())..add(Open(arguments: widget.workId)),
      child: Builder(
        builder: (context) {
          return BlocListener<HomeBloc, AppState>(
            listener: (context, state) {
              if (state is Done && state.model is WorkDetailsModel) {
                final nextValue =
                    (state.model as WorkDetailsModel).isInFavorites;
                if (nextValue != null && mounted) {
                  setState(() {
                    _isInFavorites = nextValue;
                  });
                }
              }
            },
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                CustomNavigator.pop(result: _didEdit);
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF7F9FB),
                appBar: CustomAppBar(
                  title: 'profile.works'.tr(),
                  centerTitle: true,
                  onBackPressed: () {
                    CustomNavigator.pop(result: _didEdit);
                  },
                  actions: [
                    if (_canFavourite)
                      IconButton(
                        onPressed: _isFavouriteLoading
                            ? null
                            : () => _toggleFavourite(context),
                        icon: _isFavouriteLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _isInFavorites
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isInFavorites
                                    ? const Color(0xFFDB5353)
                                    : Styles.PRIMARY_COLOR,
                              ),
                      ),
                    if (widget.canEdit)
                      IconButton(
                        onPressed: () => _openEdit(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Styles.PRIMARY_COLOR,
                        ),
                      ),
                  ],
                ),
                body: BlocBuilder<HomeBloc, AppState>(
                  builder: (context, state) {
                    if (state is Loading && widget.initialWork != null) {
                      return _WorkContent(
                        work: widget.initialWork!,
                      );
                    }

                    if (state is Loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Styles.PRIMARY_COLOR,
                        ),
                      );
                    }

                    if (state is Error) {
                      if (widget.initialWork != null) {
                        return _WorkContent(
                          work: widget.initialWork!,
                        );
                      }
                      return Center(
                        child: Text('something_went_wrong'.tr()),
                      );
                    }

                    if (state is Done && state.model is WorkDetailsModel) {
                      return _WorkContent(
                        work: state.model as WorkDetailsModel,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WorkContent extends StatelessWidget {
  const _WorkContent({
    required this.work,
  });

  final WorkDetailsModel work;

  @override
  Widget build(BuildContext context) {
    final status = ProjectStatusHelper.fromString(work.status);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: double.infinity,
              height: 240,
              child: work.image != null && work.image!.trim().isNotEmpty
                  ? Image.network(
                      work.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        work.title ?? '-',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Styles.HEADER,
                        ),
                      ),
                    ),
                    StatusChip(status: status),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _MetricCard(
                      icon: Icons.visibility_outlined,
                      label: 'project_portfolio.views'.tr(),
                      value: '${work.views ?? 0}',
                    ),
                    SizedBox(width: 12.w),
                    _MetricCard(
                      icon: Icons.thumb_up_alt_outlined,
                      label: 'project_portfolio.likes'.tr(),
                      value: '${work.likes ?? 0}',
                    ),
                  ],
                ),
                if ((work.date ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '${'account_statement_screen.date'.tr()}: ${work.date}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Styles.HINT_COLOR,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                Text(
                  work.description ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Styles.SUBTITLE,
                  ),
                ),
                if (work.skills.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(
                    'project_card_offer.skills'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: work.skills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Styles.PRIMARY_COLOR.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Styles.PRIMARY_COLOR,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if ((work.previewLink ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(
                    'preview_link'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _PreviewLinkTile(
                    url: work.previewLink!,
                    onTap: () => _launchUrl(work.previewLink!),
                  ),
                ],
                if (work.files.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(
                    'work_files'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...work.files.map(
                    (file) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WorkFileTile(
                        url: file,
                        onTap: () => _launchUrl(file),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E8A8F),
            Color(0xFF14A0A5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.work_outline, color: Colors.white, size: 48),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAFA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Styles.PRIMARY_COLOR.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Styles.PRIMARY_COLOR, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Styles.HEADER,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Styles.SUBTITLE,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewLinkTile extends StatelessWidget {
  const _PreviewLinkTile({
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5FAFA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link_outlined,
                  color: Styles.PRIMARY_COLOR,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Styles.HEADER,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: Styles.HINT_COLOR,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkFileTile extends StatelessWidget {
  const _WorkFileTile({
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fileName = Uri.tryParse(url)?.pathSegments.isNotEmpty == true
        ? Uri.parse(url).pathSegments.last
        : url;

    return Material(
      color: const Color(0xFFF5FAFA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Styles.PRIMARY_COLOR.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: Styles.PRIMARY_COLOR,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Styles.HEADER,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: Styles.HINT_COLOR,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
