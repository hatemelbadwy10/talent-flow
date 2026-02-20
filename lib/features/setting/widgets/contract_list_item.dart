import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';

enum ContractStatus { pending, rejected, approved }

class ContractListItem extends StatelessWidget {
  const ContractListItem({
    super.key,
    required this.status,
    required this.titleKey,
    required this.sizeKey,
  });

  final ContractStatus status;
  final String titleKey;
  final String sizeKey;

  @override
  Widget build(BuildContext context) {
    final statusData = _statusStyle(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  titleKey.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sizeKey.tr(),
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
                  statusData.textKey.tr(),
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
              ).visible(  status == ContractStatus.approved),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.textKey,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
  });

  final String textKey;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
}

_StatusStyle _statusStyle(ContractStatus status) {
  switch (status) {
    case ContractStatus.pending:
      return const _StatusStyle(
        textKey: 'contracts_screen.status_pending',
        icon: Icons.access_time_filled_rounded,
        textColor: Color(0xFFB56700),
        backgroundColor: Color(0xFFFFF4E4),
      );
    case ContractStatus.rejected:
      return const _StatusStyle(
        textKey: 'contracts_screen.status_rejected',
        icon: Icons.cancel_rounded,
        textColor: Color(0xFFDB5353),
        backgroundColor: Color(0xFFFFECEC),
      );
    case ContractStatus.approved:
      return const _StatusStyle(
        textKey: 'contracts_screen.status_approved',
        icon: Icons.check_circle_rounded,
        textColor: Color(0xFF209370),
        backgroundColor: Color(0xFFEAF8F1),
      );
  }
}
