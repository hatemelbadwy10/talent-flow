import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/core/app_core.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_notification.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/styles.dart';
import '../../../app/core/svg_images.dart';
import '../../../components/custom_button.dart';
import '../../../data/config/di.dart';
import '../../../features/payment/model/contract_payment_args.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../bloc/contract_details_bloc.dart';
import '../model/contract_model.dart';
import '../widgets/setting_app_bar.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class ContractDetailsScreen extends StatelessWidget {
  const ContractDetailsScreen({super.key, required this.contractId});

  final int contractId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContractDetailsBloc(sl())..add(Add(arguments: contractId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'contract_details_screen.title'.tr(),
          centerTitle: true,
        ),
        body: BlocBuilder<ContractDetailsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const ProjectCardShimmer();
            }

            if (state is Error) {
              return Center(child: Text('something_went_wrong'.tr()));
            }

            if (state is Done) {
              final contract = state.model as ContractModel?;
              if (contract == null) {
                return Center(child: Text('something_went_wrong'.tr()));
              }
              return _ContractDetailsBody(contract: contract);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ContractDetailsBody extends StatelessWidget {
  const _ContractDetailsBody({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final statusData = _statusStyle(contract.status, contract.statusLabel);
    final statusText = contract.statusLabel?.trim().isNotEmpty == true
        ? contract.statusLabel!
        : statusData.textKey.tr();
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;
    final canPay =
        !isFreelancer && contract.isPayableForOwner && contract.id != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      SvgImages.contract,
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        Styles.PRIMARY_COLOR,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.title ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID #${contract.id ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF88878B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusData.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusData.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'contract_details_screen.project_info'.tr(),
            children: [
              _InfoRow(
                title: 'contract_details_screen.project_title'.tr(),
                value: contract.projectTitle,
              ),
              _InfoRow(
                title: 'contract_details_screen.project_owner'.tr(),
                value: contract.projectOwner,
              ),
              _InfoRow(
                title: 'contract_details_screen.freelancer'.tr(),
                value: contract.freelancer,
              ),
              _InfoRow(
                title: 'contract_details_screen.project_description'.tr(),
                value: contract.projectDescription,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'contract_details_screen.contract_info'.tr(),
            children: [
              _InfoRow(
                title: 'contract_details_screen.date'.tr(),
                value: contract.date,
              ),
              _InfoRow(
                title: 'contract_details_screen.budget'.tr(),
                value: contract.budget,
              ),
              _InfoRow(
                title: 'contract_details_screen.duration'.tr(),
                value: contract.duration,
              ),
              _InfoRow(
                title: 'contract_details_screen.terms'.tr(),
                value: contract.terms,
              ),
              _InfoRow(
                title: 'contract_details_screen.talent_percentage'.tr(),
                value: contract.talentPercentageOfContracts,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HtmlCard(
            title: 'contract_details_screen.termination_conditions'.tr(),
            htmlContent: contract.terminationConditions,
          ),
          const SizedBox(height: 12),
          _HtmlCard(
            title: 'contract_details_screen.conflict_policy'.tr(),
            htmlContent: contract.conflictPolicy,
          ),
          if (canPay) ...[
            const SizedBox(height: 20),
            CustomButton(
              text: 'contract_payment.pay'.tr(),
              radius: 18,
              height: 56,
              rIconWidget: const Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: 24,
              ),
              onTap: () async {
                final detailsBloc = context.read<ContractDetailsBloc>();
                final paymentResult = await CustomNavigator.push(
                  Routes.contractPaymentRequest,
                  arguments: ContractPaymentRequestArgs(
                    contractId: contract.id!,
                    contractTitle: contract.title,
                    initialAmount: contract.suggestedPaymentAmount,
                    initialStartDate: contract.date,
                  ),
                );

                if (paymentResult is String &&
                    paymentResult.trim().isNotEmpty) {
                  AppCore.showSnackBar(
                    notification: AppNotification(
                      message: paymentResult,
                      backgroundColor: Styles.PRIMARY_COLOR,
                      isFloating: true,
                    ),
                  );
                  detailsBloc.add(Add(arguments: contract.id!));
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, this.value});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E7683),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value?.trim().isNotEmpty == true ? value! : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HtmlCard extends StatelessWidget {
  const _HtmlCard({required this.title, this.htmlContent});

  final String title;
  final String? htmlContent;

  @override
  Widget build(BuildContext context) {
    final hasData = htmlContent?.trim().isNotEmpty == true;

    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          if (!hasData)
            const Text(
              '-',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF222222),
              ),
            )
          else
            Html(
              data: htmlContent,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: const Color(0xFF222222),
                  fontSize: FontSize(14),
                  lineHeight: const LineHeight(1.5),
                ),
                'p': Style(margin: Margins.zero),
              },
            ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.textKey,
    required this.textColor,
    required this.backgroundColor,
  });

  final String textKey;
  final Color textColor;
  final Color backgroundColor;
}

_StatusStyle _statusStyle(int? status, String? statusLabel) {
  if (_isCompletedStatus(status, statusLabel)) {
    return const _StatusStyle(
      textKey: 'project_status.completed',
      textColor: Color(0xFF209370),
      backgroundColor: Color(0xFFEAF8F1),
    );
  }
  if (status == 1) {
    return const _StatusStyle(
      textKey: 'contracts_screen.status_approved',
      textColor: Color(0xFF209370),
      backgroundColor: Color(0xFFEAF8F1),
    );
  }
  if (status == 2) {
    return const _StatusStyle(
      textKey: 'contracts_screen.status_rejected',
      textColor: Color(0xFFDB5353),
      backgroundColor: Color(0xFFFFECEC),
    );
  }
  return const _StatusStyle(
    textKey: 'contracts_screen.status_pending',
    textColor: Color(0xFFB56700),
    backgroundColor: Color(0xFFFFF4E4),
  );
}

bool _isCompletedStatus(int? status, String? statusLabel) {
  final normalizedStatus = statusLabel?.trim().toLowerCase() ?? '';
  return status == 3 ||
      normalizedStatus.contains('completed') ||
      normalizedStatus.contains('مكتمل') ||
      normalizedStatus.contains('مكتملة');
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);
