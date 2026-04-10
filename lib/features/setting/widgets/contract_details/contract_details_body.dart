import 'dart:developer';

import 'package:dartz/dartz.dart' show Either;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/data/error/failures.dart';
import 'package:talent_flow/features/payment/model/contract_payment_args.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_bloc.dart';
import 'package:talent_flow/features/setting/model/contract_details_ui_model.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';
import 'package:talent_flow/features/setting/repo/contracts_repo.dart';
import 'package:talent_flow/features/setting/widgets/contract_details/contract_details_components.dart';
import 'package:talent_flow/features/setting/widgets/contract_details/contract_details_dialogs.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

typedef ContractActionRequest = Future<Either<ServerFailure, Response>>
    Function();

class ContractDetailsBody extends StatefulWidget {
  const ContractDetailsBody({
    super.key,
    required this.contract,
    required this.onContractUpdated,
  });

  final ContractModel contract;
  final VoidCallback onContractUpdated;

  @override
  State<ContractDetailsBody> createState() => _ContractDetailsBodyState();
}

class _ContractDetailsBodyState extends State<ContractDetailsBody> {
  final ContractsRepo _contractsRepo = sl();
  String? _activeActionKey;

  ContractModel get _contract => widget.contract;

  bool _isActionLoading(String actionKey) => _activeActionKey == actionKey;

  Future<void> _handleApproveContract() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    await _runContractAction(
      actionKey: 'approve_contract',
      request: () => _contractsRepo.approveContract(contractId),
    );
  }

  Future<void> _handleRejectContract() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final reason = await _showTextActionDialog(
      title: 'contract_details_screen.actions.reject_contract'.tr(),
      hint: 'contract_details_screen.hints.reject_reason'.tr(),
      submitText: 'contract_details_screen.common.submit'.tr(),
    );

    if (reason == null) return;

    await _runContractAction(
      actionKey: 'reject_contract',
      request: () => _contractsRepo.rejectContract(
        contractId: contractId,
        reason: reason,
      ),
    );
  }

  Future<void> _handleGoToPayment() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final detailsBloc = context.read<ContractDetailsBloc>();
    final paymentResult = await CustomNavigator.push(
      Routes.contractPaymentRequest,
      arguments: ContractPaymentRequestArgs(
        contractId: contractId,
        contractTitle: _contract.title,
        initialAmount: _contract.suggestedPaymentAmount,
        initialStartDate: _contract.date,
      ),
    );

    if (!mounted) return;

    if (paymentResult is String && paymentResult.trim().isNotEmpty) {
      _showSuccess(paymentResult);
      widget.onContractUpdated();
      detailsBloc.add(Add(arguments: contractId));
    }
  }

  Future<void> _handleMarkAsCompleted() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    await _runContractAction(
      actionKey: 'mark_completed',
      request: () => _contractsRepo.markWorkCompleted(contractId),
    );
  }

  Future<void> _handleHaveNotes() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final reason = await _showTextActionDialog(
      title: 'contract_details_screen.actions.have_notes'.tr(),
      hint: 'contract_details_screen.hints.work_notes'.tr(),
      submitText: 'contract_details_screen.common.submit'.tr(),
    );

    if (reason == null) return;

    await _runContractAction(
      actionKey: 'have_notes',
      request: () => _contractsRepo.rejectWorkWithNotes(
        contractId: contractId,
        reason: reason,
      ),
    );
  }

  Future<void> _handleSubmitComplaint() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final content = await _showTextActionDialog(
      title: 'contract_details_screen.actions.submit_complaint'.tr(),
      hint: 'contract_details_screen.hints.complaint'.tr(),
      submitText: 'contract_details_screen.common.submit'.tr(),
    );

    if (content == null) return;

    await _runContractAction(
      actionKey: 'submit_complaint',
      request: () => _contractsRepo.submitComplaint(
        contractId: contractId,
        content: content,
      ),
    );
  }

  Future<void> _handleAcceptCloseProject() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final reviewInput = await _showReviewDialog(
      title: 'contract_details_screen.actions.accept_close_project'.tr(),
    );

    if (reviewInput == null) return;

    await _runContractAction(
      actionKey: 'accept_close_project',
      request: () => _contractsRepo.closeContractAndReview(
        contractId: contractId,
        comment: reviewInput.comment,
        rating: reviewInput.rating,
      ),
    );
  }

  Future<void> _handleReviewEntrepreneur() async {
    final contractId = _contract.id;
    if (contractId == null) return;

    final reviewInput = await _showReviewDialog(
      title: 'contract_details_screen.actions.review_entrepreneur'.tr(),
    );

    if (reviewInput == null) return;

    await _runContractAction(
      actionKey: 'review_entrepreneur',
      request: () => _contractsRepo.reviewEntrepreneur(
        contractId: contractId,
        comment: reviewInput.comment,
        rating: reviewInput.rating,
      ),
    );
  }

  Future<void> _handleEditContract() async {
    final contractId = _contract.id;
    final projectId = _contract.projectId;
    final freelancerId = _contract.freelancerId;

    if (contractId == null || projectId == null || freelancerId == null) {
      _showError('something_went_wrong'.tr());
      log(
        'Missing data for editing contract: '
        'contractId=$contractId, projectId=$projectId, freelancerId=$freelancerId',
      );
      return;
    }

    final result = await CustomNavigator.push(
      Routes.createContract,
      arguments: {
        'contractId': contractId,
        'projectId': projectId,
        'freelancerId': freelancerId,
        'contract': _contract,
      },
    );

    if (!mounted || result != true) {
      return;
    }

    widget.onContractUpdated();
    context.read<ContractDetailsBloc>().add(Add(arguments: contractId));
  }

  Future<void> _runContractAction({
    required String actionKey,
    required ContractActionRequest request,
  }) async {
    if (_activeActionKey != null) return;

    setState(() {
      _activeActionKey = actionKey;
    });

    final result = await request();
    if (!mounted) return;

    result.fold(
      (failure) => _showError(failure.error),
      (response) {
        final message = _extractMessage(response);
        _showSuccess(message);
        widget.onContractUpdated();
        final contractId = _contract.id;
        if (contractId != null) {
          context.read<ContractDetailsBloc>().add(Add(arguments: contractId));
        }
      },
    );

    if (!mounted) return;
    setState(() {
      _activeActionKey = null;
    });
  }

  String _extractMessage(Response response) {
    final data = response.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'contract_details_screen.common.action_completed'.tr();
  }

  void _showError(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
      ),
    );
  }

  void _showSuccess(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.PRIMARY_COLOR,
        isFloating: true,
      ),
    );
  }

  Future<String?> _showTextActionDialog({
    required String title,
    required String hint,
    required String submitText,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => TextActionDialog(
        title: title,
        hint: hint,
        submitText: submitText,
      ),
    );
  }

  Future<ReviewDialogResult?> _showReviewDialog({required String title}) {
    return showDialog<ReviewDialogResult>(
      context: context,
      builder: (context) => ReviewActionDialog(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;
    final uiModel = ContractDetailsUiModel(
      contract: _contract,
      isFreelancer: isFreelancer,
      isEntrepreneur: !isFreelancer,
    );
    final statusStyle = contractDetailsStatusStyle(uiModel.status);
    final complaintMessage = uiModel.complaintMessage();
    final actionButtons = _buildActionButtons(uiModel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContractDetailsSummaryCard(
            contract: _contract,
            statusLabel: uiModel.getStatusLabel(),
            statusStyle: statusStyle,
          ),
          const SizedBox(height: 12),
          ContractDetailsInfoCard(
            title: 'contract_details_screen.project_info'.tr(),
            children: [
              ContractDetailsInfoRow(
                title: 'contract_details_screen.project_title'.tr(),
                value: _contract.projectTitle,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.project_owner'.tr(),
                value: _contract.projectOwner,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.freelancer'.tr(),
                value: _contract.freelancer,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.project_description'.tr(),
                value: _contract.projectDescription,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ContractDetailsInfoCard(
            title: 'contract_details_screen.contract_info'.tr(),
            children: [
              ContractDetailsInfoRow(
                title: 'contract_details_screen.date'.tr(),
                value: _contract.date,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.budget'.tr(),
                value: _contract.budget,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.duration'.tr(),
                value: _contract.duration,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.terms'.tr(),
                value: _contract.terms,
              ),
              ContractDetailsInfoRow(
                title: 'contract_details_screen.talent_percentage'.tr(),
                value: _contract.talentPercentageOfContracts,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ContractDetailsHtmlCard(
            title: 'contract_details_screen.termination_conditions'.tr(),
            htmlContent: _contract.terminationConditions,
          ),
          const SizedBox(height: 12),
          ContractDetailsHtmlCard(
            title: 'contract_details_screen.conflict_policy'.tr(),
            htmlContent: _contract.conflictPolicy,
          ),
          if (uiModel.shouldShowRejectWorkNotes()) ...[
            const SizedBox(height: 12),
            ContractDetailsTextCard(
              title: 'contract_details_screen.sections.has_notes'.tr(),
              value: uiModel.rejectWorkNotesText,
            ),
          ],
          if (uiModel.shouldShowRejectReason()) ...[
            const SizedBox(height: 12),
            ContractDetailsTextCard(
              title: 'contract_details_screen.sections.reject_reason'.tr(),
              value: uiModel.rejectReasonText,
            ),
          ],
          if (complaintMessage != null) ...[
            const SizedBox(height: 12),
            ContractDetailsMessageCard(message: complaintMessage),
          ],
          if (actionButtons.isNotEmpty) ...[
            const SizedBox(height: 20),
            ContractDetailsInfoCard(
              title: 'contract_details_screen.actions.title'.tr(),
              children: actionButtons,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(ContractDetailsUiModel uiModel) {
    final buttons = <Widget>[];

    void addButton(Widget button) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(height: 10));
      }
      buttons.add(button);
    }

    if (uiModel.canApproveContract()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.approve_contract'.tr(),
          isLoading: _isActionLoading('approve_contract'),
          onTap: _handleApproveContract,
        ),
      );
    }

    if (uiModel.canRejectContract()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.reject_contract'.tr(),
          isLoading: _isActionLoading('reject_contract'),
          onTap: _handleRejectContract,
          backgroundColor: Colors.white,
          textColor: const Color(0xFFDB5353),
          borderColor: const Color(0xFFDB5353),
          withBorder: true,
        ),
      );
    }

    if (uiModel.canEditContract()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.edit_contract'.tr(),
          isLoading: false,
          onTap: _handleEditContract,
          backgroundColor: Colors.white,
          textColor: Styles.PRIMARY_COLOR,
          borderColor: Styles.PRIMARY_COLOR,
          withBorder: true,
        ),
      );
    }

    if (uiModel.canGoToPayment()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.go_to_payment'.tr(),
          isLoading: false,
          onTap: _handleGoToPayment,
        ),
      );
    }

    if (uiModel.canMarkAsCompleted()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.mark_as_completed'.tr(),
          isLoading: _isActionLoading('mark_completed'),
          onTap: _handleMarkAsCompleted,
        ),
      );
    }

    if (uiModel.canReviewEntrepreneur()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.review_entrepreneur'.tr(),
          isLoading: _isActionLoading('review_entrepreneur'),
          onTap: _handleReviewEntrepreneur,
        ),
      );
    }

    if (uiModel.canAcceptCloseProject()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.accept_close_project'.tr(),
          isLoading: _isActionLoading('accept_close_project'),
          onTap: _handleAcceptCloseProject,
        ),
      );
    }

    if (uiModel.canHaveNotes()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.have_notes'.tr(),
          isLoading: _isActionLoading('have_notes'),
          onTap: _handleHaveNotes,
          backgroundColor: Colors.white,
          textColor: const Color(0xFF9A6400),
          borderColor: const Color(0xFF9A6400),
          withBorder: true,
        ),
      );
    }

    if (uiModel.canSubmitComplaint()) {
      addButton(
        ContractDetailsActionButton(
          text: 'contract_details_screen.actions.submit_complaint'.tr(),
          isLoading: _isActionLoading('submit_complaint'),
          onTap: _handleSubmitComplaint,
          backgroundColor: Colors.white,
          textColor: const Color(0xFF7347D6),
          borderColor: const Color(0xFF7347D6),
          withBorder: true,
        ),
      );
    }

    return buttons;
  }
}
