import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';

class ContractListItem extends StatelessWidget {
  const ContractListItem({
    super.key,
    required this.contract,
    this.onTap,
  });

  final ContractModel contract;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusData = _statusStyle(contract.status, contract.statusLabel);
    final statusText = contract.statusLabel?.trim().isNotEmpty == true
        ? contract.statusLabel!
        : statusData.textKey.tr();
    final isApproved = contract.status == 1;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.PRIMARY_COLOR.withValues(alpha: 0.08),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.PRIMARY_COLOR.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgImages.contract,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Styles.PRIMARY_COLOR,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
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
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID #${contract.id ?? '-'}',
                      style: const TextStyle(
                        color: Color(0xFF88878B),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusData.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusData.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    color: Styles.PRIMARY_COLOR,
                    tooltip: 'contracts_screen.download'.tr(),
                  ).visible(isApproved),
                ],
              ),
            ],
          ),
        ),
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
