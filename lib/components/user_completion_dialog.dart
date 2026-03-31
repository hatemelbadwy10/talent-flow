import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app/core/styles.dart';
import '../app/core/user_completion_guard.dart';
import 'custom_button.dart';

class UserCompletionDialog extends StatelessWidget {
  const UserCompletionDialog({
    super.key,
    required this.action,
    required this.missingRequirements,
    required this.primaryLabelKey,
    required this.onPrimaryTap,
  });

  final GuardedAction action;
  final List<MissingRequirement> missingRequirements;
  final String primaryLabelKey;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Styles.PRIMARY_COLOR.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Styles.PRIMARY_COLOR,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Styles.HINT_COLOR),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _titleKey.tr(),
              style: const TextStyle(
                color: Styles.HEADER,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'user_completion.subtitle'.tr(),
              style: const TextStyle(
                color: Styles.HINT_COLOR,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: missingRequirements
                    .map(
                      (requirement) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Styles.PRIMARY_COLOR,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _requirementKey(requirement).tr(),
                                style: const TextStyle(
                                  color: Styles.HEADER,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'user_completion.cancel'.tr(),
                    backgroundColor: Colors.white,
                    textColor: Styles.PRIMARY_COLOR,
                    borderColor: Styles.PRIMARY_COLOR,
                    withBorderColor: true,
                    radius: 16,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: primaryLabelKey.tr(),
                    radius: 16,
                    onTap: onPrimaryTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _titleKey {
    switch (action) {
      case GuardedAction.addProject:
        return 'user_completion.add_project_blocked_title';
      case GuardedAction.addOffer:
        return 'user_completion.add_offer_blocked_title';
    }
  }

  String _requirementKey(MissingRequirement requirement) {
    switch (requirement) {
      case MissingRequirement.addedWorks:
        return 'user_completion.missing_work';
      case MissingRequirement.bankAccount:
        return 'user_completion.missing_bank_account';
      case MissingRequirement.identityVerification:
        return 'user_completion.missing_identity';
    }
  }
}
