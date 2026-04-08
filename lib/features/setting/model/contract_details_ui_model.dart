import 'package:easy_localization/easy_localization.dart';

import 'contract_model.dart';
import 'contract_status.dart';

class ContractDetailsUiModel {
  const ContractDetailsUiModel({
    required this.contract,
    required this.isFreelancer,
    required this.isEntrepreneur,
  });

  final ContractModel contract;
  final bool isFreelancer;
  final bool isEntrepreneur;

  ContractStatus get status => ContractStatus.fromBackend(contract.status);

  bool get _hasContractId => contract.id != null;
  bool get _hasRejectWorkNotes =>
      (contract.rejectWorkNotes?.trim().isNotEmpty ?? false);
  String getStatusLabel() {
    switch (status) {
      case ContractStatus.accepted:
        return 'contract_details_screen.status.accepted'.tr();
      case ContractStatus.pending:
        return 'contract_details_screen.status.pending'.tr();
      case ContractStatus.inProgress:
        return 'contract_details_screen.status.in_progress'.tr();
      case ContractStatus.workUnderReview:
        return 'contract_details_screen.status.work_under_review'.tr();
      case ContractStatus.waitToPayFreelancer:
        return 'contract_details_screen.status.wait_to_pay_freelancer'.tr();
      case ContractStatus.hasNotes:
        return 'contract_details_screen.status.has_notes'.tr();
      case ContractStatus.disagreement:
        return 'contract_details_screen.status.disagreement'.tr();
      case ContractStatus.closed:
        return 'contract_details_screen.status.closed'.tr();
      case ContractStatus.rejected:
        return 'contract_details_screen.status.rejected'.tr();
    }
  }

  bool canApproveContract() =>
      _hasContractId && status == ContractStatus.pending && isFreelancer;

  bool canRejectContract() =>
      _hasContractId && status == ContractStatus.pending && isFreelancer;

  bool canEditContract() => status == ContractStatus.rejected && isEntrepreneur;

  bool canGoToPayment() =>
      _hasContractId && status == ContractStatus.accepted && isEntrepreneur;

  bool canMarkAsCompleted() =>
      _hasContractId && status == ContractStatus.inProgress && isFreelancer;

  bool canReviewEntrepreneur() =>
      _hasContractId &&
      status == ContractStatus.waitToPayFreelancer &&
      isFreelancer &&
      !contract.userHasSubmittedReview;

  bool canAcceptCloseProject() =>
      _hasContractId &&
      status == ContractStatus.workUnderReview &&
      isEntrepreneur;

  bool canHaveNotes() =>
      _hasContractId &&
      status == ContractStatus.workUnderReview &&
      isEntrepreneur;

  bool canSubmitComplaint() =>
      _hasContractId &&
      (status == ContractStatus.inProgress ||
          status == ContractStatus.workUnderReview ||
          status == ContractStatus.disagreement) &&
      _hasRejectWorkNotes &&
      !contract.userHasSubmittedComplaint;

  bool shouldShowRejectWorkNotes() =>
      status == ContractStatus.inProgress && _hasRejectWorkNotes;

  bool shouldShowRejectReason() =>
      status == ContractStatus.rejected && isEntrepreneur;

  String? complaintMessage() {
    if (status != ContractStatus.disagreement) {
      return null;
    }

    if (contract.userHasSubmittedComplaint) {
      return 'contract_details_screen.complaint.submitted_by_you'.tr();
    }

    return 'contract_details_screen.complaint.submitted_by_other_party'.tr();
  }

  String get rejectWorkNotesText => contract.rejectWorkNotes?.trim() ?? '';
  String get rejectReasonText => contract.rejectReason?.trim() ?? '';
}
