import 'dart:developer';

import 'package:dartz/dartz.dart' show Either;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../data/error/failures.dart';
import '../../../features/payment/model/contract_payment_args.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../bloc/contract_details_bloc.dart';
import '../model/contract_details_ui_model.dart';
import '../model/contract_model.dart';
import '../model/contract_status.dart';
import '../repo/contracts_repo.dart';
import '../widgets/setting_app_bar.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

typedef ContractActionRequest = Future<Either<ServerFailure, Response>>
    Function();

class ContractDetailsScreen extends StatefulWidget {
  const ContractDetailsScreen({super.key, required this.contractId});

  final int contractId;

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  bool _shouldRefreshOnPop = false;

  void _markUpdated() {
    _shouldRefreshOnPop = true;
  }

  Future<bool> _handleWillPop() async {
    Navigator.of(context).pop(_shouldRefreshOnPop);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleWillPop();
      },
      child: BlocProvider(
        create: (_) =>
            ContractDetailsBloc(sl())..add(Add(arguments: widget.contractId)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: CustomAppBar(
            title: 'contract_details_screen.title'.tr(),
            centerTitle: true,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(_shouldRefreshOnPop),
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
                return _ContractDetailsBody(
                  contract: contract,
                  onContractUpdated: _markUpdated,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ContractDetailsBody extends StatefulWidget {
  const _ContractDetailsBody({
    required this.contract,
    required this.onContractUpdated,
  });

  final ContractModel contract;
  final VoidCallback onContractUpdated;

  @override
  State<_ContractDetailsBody> createState() => _ContractDetailsBodyState();
}

class _ContractDetailsBodyState extends State<_ContractDetailsBody> {
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
      log("Missing data for editing contract: contractId=$contractId, projectId=$projectId, freelancerId=$freelancerId");
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
      builder: (context) => _TextActionDialog(
        title: title,
        hint: hint,
        submitText: submitText,
      ),
    );
  }

  Future<_ReviewDialogResult?> _showReviewDialog({required String title}) {
    return showDialog<_ReviewDialogResult>(
      context: context,
      builder: (context) => _ReviewActionDialog(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;
    final isEntrepreneur = !isFreelancer;
    final uiModel = ContractDetailsUiModel(
      contract: _contract,
      isFreelancer: isFreelancer,
      isEntrepreneur: isEntrepreneur,
    );
    final statusData = _statusStyle(uiModel.status);
    final actionButtons = _buildActionButtons(uiModel);

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
                        _contract.title ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID #${_contract.id ?? '-'}',
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
                    uiModel.getStatusLabel(),
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
                value: _contract.projectTitle,
              ),
              _InfoRow(
                title: 'contract_details_screen.project_owner'.tr(),
                value: _contract.projectOwner,
              ),
              _InfoRow(
                title: 'contract_details_screen.freelancer'.tr(),
                value: _contract.freelancer,
              ),
              _InfoRow(
                title: 'contract_details_screen.project_description'.tr(),
                value: _contract.projectDescription,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'contract_details_screen.contract_info'.tr(),
            children: [
              _InfoRow(
                title: 'contract_details_screen.date'.tr(),
                value: _contract.date,
              ),
              _InfoRow(
                title: 'contract_details_screen.budget'.tr(),
                value: _contract.budget,
              ),
              _InfoRow(
                title: 'contract_details_screen.duration'.tr(),
                value: _contract.duration,
              ),
              _InfoRow(
                title: 'contract_details_screen.terms'.tr(),
                value: _contract.terms,
              ),
              _InfoRow(
                title: 'contract_details_screen.talent_percentage'.tr(),
                value: _contract.talentPercentageOfContracts,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HtmlCard(
            title: 'contract_details_screen.termination_conditions'.tr(),
            htmlContent: _contract.terminationConditions,
          ),
          const SizedBox(height: 12),
          _HtmlCard(
            title: 'contract_details_screen.conflict_policy'.tr(),
            htmlContent: _contract.conflictPolicy,
          ),
          if (uiModel.shouldShowRejectWorkNotes()) ...[
            const SizedBox(height: 12),
            _TextCard(
              title: 'contract_details_screen.sections.has_notes'.tr(),
              value: uiModel.rejectWorkNotesText,
            ),
          ],
          if (uiModel.shouldShowRejectReason()) ...[
            const SizedBox(height: 12),
            _TextCard(
              title: 'contract_details_screen.sections.reject_reason'.tr(),
              value: uiModel.rejectReasonText,
            ),
          ],
          if (uiModel.complaintMessage() != null) ...[
            const SizedBox(height: 12),
            _MessageCard(message: uiModel.complaintMessage()!),
          ],
          if (actionButtons.isNotEmpty) ...[
            const SizedBox(height: 20),
            _InfoCard(
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
        _ActionButton(
          text: 'contract_details_screen.actions.approve_contract'.tr(),
          isLoading: _isActionLoading('approve_contract'),
          onTap: _handleApproveContract,
        ),
      );
    }

    if (uiModel.canRejectContract()) {
      addButton(
        _ActionButton(
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
        _ActionButton(
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
        _ActionButton(
          text: 'contract_details_screen.actions.go_to_payment'.tr(),
          isLoading: false,
          onTap: _handleGoToPayment,
        ),
      );
    }

    if (uiModel.canMarkAsCompleted()) {
      addButton(
        _ActionButton(
          text: 'contract_details_screen.actions.mark_as_completed'.tr(),
          isLoading: _isActionLoading('mark_completed'),
          onTap: _handleMarkAsCompleted,
        ),
      );
    }

    if (uiModel.canReviewEntrepreneur()) {
      addButton(
        _ActionButton(
          text: 'contract_details_screen.actions.review_entrepreneur'.tr(),
          isLoading: _isActionLoading('review_entrepreneur'),
          onTap: _handleReviewEntrepreneur,
        ),
      );
    }

    if (uiModel.canAcceptCloseProject()) {
      addButton(
        _ActionButton(
          text: 'contract_details_screen.actions.accept_close_project'.tr(),
          isLoading: _isActionLoading('accept_close_project'),
          onTap: _handleAcceptCloseProject,
        ),
      );
    }

    if (uiModel.canHaveNotes()) {
      addButton(
        _ActionButton(
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
        _ActionButton(
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.backgroundColor = Styles.PRIMARY_COLOR,
    this.textColor = Colors.white,
    this.borderColor,
    this.withBorder = false,
  });

  final String text;
  final bool isLoading;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      height: 52,
      radius: 14,
      isLoading: isLoading,
      onTap: onTap,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      withBorderColor: withBorder,
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

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.value});

  final String title;
  final String value;

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
          const SizedBox(height: 8),
          Text(
            value.trim().isNotEmpty ? value : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9CCFF)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF7347D6),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E2A7A),
                height: 1.5,
              ),
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

class _TextActionDialog extends StatefulWidget {
  const _TextActionDialog({
    required this.title,
    required this.hint,
    required this.submitText,
  });

  final String title;
  final String hint;
  final String submitText;

  @override
  State<_TextActionDialog> createState() => _TextActionDialogState();
}

class _TextActionDialogState extends State<_TextActionDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'contract_details_screen.validation.required'.tr();
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('contract_details_screen.common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: Text(widget.submitText),
        ),
      ],
    );
  }
}

class _ReviewActionDialog extends StatefulWidget {
  const _ReviewActionDialog({required this.title});

  final String title;

  @override
  State<_ReviewActionDialog> createState() => _ReviewActionDialogState();
}

class _ReviewActionDialogState extends State<_ReviewActionDialog> {
  final _commentController = TextEditingController();
  final _ratingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'contract_details_screen.hints.review_comment'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'contract_details_screen.validation.required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ratingController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              decoration: InputDecoration(
                hintText: 'contract_details_screen.hints.rating'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'contract_details_screen.validation.required'.tr();
                }

                final rating = double.tryParse(value!.trim());
                if (rating == null || rating < 0 || rating > 5) {
                  return 'contract_details_screen.validation.rating'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('contract_details_screen.common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(
              _ReviewDialogResult(
                comment: _commentController.text.trim(),
                rating: _ratingController.text.trim(),
              ),
            );
          },
          child: Text('contract_details_screen.common.submit'.tr()),
        ),
      ],
    );
  }
}

class _ReviewDialogResult {
  const _ReviewDialogResult({
    required this.comment,
    required this.rating,
  });

  final String comment;
  final String rating;
}

class _StatusStyle {
  const _StatusStyle({
    required this.textColor,
    required this.backgroundColor,
  });

  final Color textColor;
  final Color backgroundColor;
}

_StatusStyle _statusStyle(ContractStatus status) {
  switch (status) {
    case ContractStatus.accepted:
    case ContractStatus.closed:
      return const _StatusStyle(
        textColor: Color(0xFF209370),
        backgroundColor: Color(0xFFEAF8F1),
      );
    case ContractStatus.pending:
    case ContractStatus.waitToPayFreelancer:
    case ContractStatus.hasNotes:
      return const _StatusStyle(
        textColor: Color(0xFFB56700),
        backgroundColor: Color(0xFFFFF4E4),
      );
    case ContractStatus.inProgress:
    case ContractStatus.workUnderReview:
      return const _StatusStyle(
        textColor: Color(0xFF2859C5),
        backgroundColor: Color(0xFFEAF0FF),
      );
    case ContractStatus.disagreement:
      return const _StatusStyle(
        textColor: Color(0xFF7347D6),
        backgroundColor: Color(0xFFF3F0FF),
      );
    case ContractStatus.rejected:
      return const _StatusStyle(
        textColor: Color(0xFFDB5353),
        backgroundColor: Color(0xFFFFECEC),
      );
  }
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
