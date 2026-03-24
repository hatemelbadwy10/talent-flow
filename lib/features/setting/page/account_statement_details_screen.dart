import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../bloc/account_statement_details_bloc.dart';
import '../model/account_statement_response_model.dart';
import '../widgets/setting_app_bar.dart';

class AccountStatementDetailsScreen extends StatelessWidget {
  const AccountStatementDetailsScreen({super.key, required this.statementId});

  final int statementId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountStatementDetailsBloc(sl())..add(Add(arguments: statementId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'account_statement_details_screen.title'.tr(),
          centerTitle: true,
        ),
        body: BlocBuilder<AccountStatementDetailsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is Error) {
              return Center(
                child: Text('something_went_wrong'.tr()),
              );
            }

            if (state is Done) {
              final model = state.model as AccountStatementItemModel?;
              if (model == null) {
                return Center(
                  child: Text('account_statement_details_screen.empty'.tr()),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'account_statement_details_screen.summary'.tr(),
                      child: Column(
                        children: [
                          _InfoRow(
                            title: 'account_statement_screen.project_name'.tr(),
                            value: model.projectName,
                          ),
                          _InfoRow(
                            title: 'account_statement_screen.service_provider'
                                .tr(),
                            value: model.serviceProviderName,
                          ),
                          _InfoRow(
                            title: 'account_statement_screen.date'.tr(),
                            value: model.date,
                          ),
                          _InfoRow(
                            title: 'project_card_offer.status'.tr(),
                            value: model.status,
                          ),
                          _InfoRow(
                            title:
                                'account_statement_details_screen.views'.tr(),
                            value: model.views?.toString(),
                          ),
                          _InfoRow(
                            title:
                                'account_statement_details_screen.since'.tr(),
                            value: model.since,
                          ),
                          _InfoRow(
                            title: 'project_card_offer.budget'.tr(),
                            value: model.budget,
                          ),
                          _InfoRow(
                            title: 'project_card_offer.duration'.tr(),
                            value: model.duration?.toString(),
                          ),
                          _InfoRow(
                            title: 'account_statement_screen.project_cost'.tr(),
                            value: model.projectCost,
                          ),
                          _InfoRow(
                            title:
                                'account_statement_screen.commission_paid'.tr(),
                            value: model.commissionPaid,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    if ((model.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title:
                            'account_statement_details_screen.description'.tr(),
                        child: Text(
                          model.description!,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (model.owner != null) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'account_statement_details_screen.owner_section'
                            .tr(),
                        child: _OwnerCard(owner: model.owner!),
                      ),
                    ],
                    if (model.proposals?.count != null) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title:
                            'account_statement_details_screen.proposals_section'
                                .tr(),
                        child: _InfoRow(
                          title:
                              'account_statement_details_screen.proposals_count'
                                  .tr(),
                          value: model.proposals!.count?.toString(),
                          showDivider: false,
                        ),
                      ),
                    ],
                    if (model.files.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'account_statement_details_screen.files_section'
                            .tr(),
                        child: Column(
                          children: model.files
                              .map(
                                (file) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _FileTile(
                                    url: file,
                                    onTap: () => _launchUrl(file),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({
    required this.owner,
  });

  final AccountStatementOwnerModel owner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF3F4F6),
              backgroundImage: (owner.image ?? '').trim().isNotEmpty
                  ? NetworkImage(owner.image!)
                  : null,
              child: (owner.image ?? '').trim().isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF6B7280))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner.name?.trim().isNotEmpty == true ? owner.name! : '-',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((owner.jobTitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      owner.jobTitle!,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoRow(
          title: 'project_card_offer.registration_date'.tr(),
          value: owner.signupDate,
        ),
        _InfoRow(
          title: 'project_card_offer.hiring_rate'.tr(),
          value: owner.employmentRate,
          showDivider: false,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
    this.showDivider = true,
  });

  final String title;
  final String? value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  value?.trim().isNotEmpty == true ? value! : '-',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFF0F2F5)),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final fileName = uri != null && uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : url;

    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.attach_file,
                color: Color(0xFF6B7280),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
