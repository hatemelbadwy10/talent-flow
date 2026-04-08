enum ContractStatus {
  rejected,
  accepted,
  pending,
  inProgress,
  workUnderReview,
  waitToPayFreelancer,
  hasNotes,
  disagreement,
  closed;

  factory ContractStatus.fromBackend(int? value) {
    switch (value) {
      case 1:
        return ContractStatus.accepted;
      case 2:
        return ContractStatus.pending;
      case 3:
        return ContractStatus.inProgress;
      case 4:
        return ContractStatus.workUnderReview;
      case 5:
        return ContractStatus.waitToPayFreelancer;
      case 6:
        return ContractStatus.hasNotes;
      case 7:
        return ContractStatus.disagreement;
      case 8:
        return ContractStatus.closed;
      case 0:
      default:
        return ContractStatus.rejected;
    }
  }
}
