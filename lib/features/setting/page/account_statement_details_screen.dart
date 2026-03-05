import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                child: Container(
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
                        'account_statement_details_screen.summary'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        title: 'account_statement_screen.project_name'.tr(),
                        value: model.projectName,
                      ),
                      _InfoRow(
                        title: 'account_statement_screen.service_provider'.tr(),
                        value: model.serviceProviderName,
                      ),
                      _InfoRow(
                        title: 'account_statement_screen.date'.tr(),
                        value: model.date,
                      ),
                      _InfoRow(
                        title: 'account_statement_screen.project_cost'.tr(),
                        value: model.projectCost,
                      ),
                      _InfoRow(
                        title: 'account_statement_screen.commission_paid'.tr(),
                        value: model.commissionPaid,
                      ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
