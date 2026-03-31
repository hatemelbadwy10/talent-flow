import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/bloc/dashboard_bloc.dart';
import 'package:talent_flow/features/setting/model/dashboard_response_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(sl())..add(Add()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: CustomAppBar(
          title: 'settings_screen.dashboard'.tr(),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton.icon(
                onPressed: () async {
                  final isFreelancer = sl<SharedPreferences>()
                          .getBool(AppStorageKey.isFreelancer) ??
                      true;
                  if (!isFreelancer) {
                    final allowed =
                        await UserCompletionGuard.ensureCanAddProject(context);
                    if (!allowed) return;
                  }
                  CustomNavigator.push(
                    isFreelancer ? Routes.addYourProject : Routes.addProject,
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مشروع'),
                style: TextButton.styleFrom(
                  foregroundColor: Styles.PRIMARY_COLOR,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is Error) {
              return Center(
                child: Text('something_went_wrong'.tr()),
              );
            }

            final model =
                state is Done ? state.model as DashboardResponseModel? : null;
            return _DashboardBody(model: model);
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.model});

  final DashboardResponseModel? model;

  @override
  Widget build(BuildContext context) {
    final balances = model?.balances;
    final counters = model?.counters;
    final statuses = model?.statuses ?? const <DashboardStatusModel>[];
    final recentProjects =
        model?.recentProjects ?? const <DashboardRecentProjectModel>[];

    final safeStatuses = statuses.isNotEmpty
        ? statuses
        : const [
            DashboardStatusModel(name: 'مسودة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'مفتوحة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'مكتملة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'ملغاة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'قيد المراجعة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'قيد التنفيذ', count: 0, percentage: 0),
            DashboardStatusModel(name: 'مغلقة', count: 0, percentage: 0),
            DashboardStatusModel(name: 'مرفوضة', count: 0, percentage: 0),
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceCell(
                        title: 'الرصيد الكلي',
                        value: balances?.totalBalance ?? '00.00',
                        subValue: '${balances?.totalBalance ?? '00.00'} ريال',
                        titleColor: Styles.PRIMARY_COLOR,
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _buildBalanceCell(
                        title: 'الرصيد القابل للسحب',
                        value: balances?.withdrawableBalance ?? '00.00',
                        subValue:
                            '${balances?.withdrawableBalance ?? '00.00'} ريال',
                        titleColor: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE8E8E8)),
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleBalance(
                        title: 'الرصيد المعلق',
                        value: balances?.pendingBalance ?? '00.00',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _buildSimpleBalance(
                        title: 'الرصيد الناتج',
                        value: balances?.outgoingBalance ?? '00.00',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(child: _HeadText('مشاريعي')),
                    Expanded(child: _HeadText('الرسائل الجديدة')),
                    Expanded(child: _HeadText('الرسائل الواردة')),
                    Expanded(child: _HeadText('العقود')),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE8E8E8)),
                Row(
                  children: [
                    Expanded(
                      child: _CountText('${counters?.myProjects ?? 0}'),
                    ),
                    Expanded(
                      child: _CountText('${counters?.newMessages ?? 0}'),
                    ),
                    Expanded(
                      child: _CountText('${counters?.incomingMessages ?? 0}'),
                    ),
                    Expanded(
                      child: _CountText('${counters?.contracts ?? 0}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: safeStatuses
                  .map(
                    (status) => _StatusBarItem(
                      title: status.name ?? '-',
                      count: status.count ?? 0,
                      percentage: status.percentage ?? 0,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (recentProjects.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أحدث المشاريع',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recentProjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final project = entry.value;
                    return Column(
                      children: [
                        _RecentProjectItem(project: project),
                        if (index != recentProjects.length - 1)
                          const Divider(
                            height: 14,
                            color: Color(0xFFE8E8E8),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFE8E8E8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBalanceCell({
    required String title,
    required String value,
    required String subValue,
    required Color titleColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subValue,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSimpleBalance({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _HeadText extends StatelessWidget {
  const _HeadText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

class _CountText extends StatelessWidget {
  const _CountText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    );
  }
}

class _StatusBarItem extends StatelessWidget {
  const _StatusBarItem({
    required this.title,
    required this.count,
    required this.percentage,
  });

  final String title;
  final int count;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final boundedValue =
        percentage.isNaN ? 0.0 : percentage.clamp(0, 100).toDouble() / 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: boundedValue,
                    minHeight: 6,
                    color: Styles.PRIMARY_COLOR.withValues(alpha: 0.95),
                    backgroundColor: const Color(0xFFE5E5E5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title $count',
                style: const TextStyle(
                  color: Color(0xFF5B5B5B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentProjectItem extends StatelessWidget {
  const _RecentProjectItem({required this.project});

  final DashboardRecentProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${project.ownerName ?? '-'} • ${project.createdAt ?? '-'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${project.proposalsCount ?? 0} عرض',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Styles.PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}
