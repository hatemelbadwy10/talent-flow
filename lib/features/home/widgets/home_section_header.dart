import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/styles.dart';

class HomeSectionHeader extends StatelessWidget {
  final String titleKey;
  final String viewAllKey;
  final VoidCallback? onViewAll;
  final bool isLoading;
  final bool showViewAll;

  const HomeSectionHeader({
    super.key,
    required this.titleKey,
    this.viewAllKey = "home.view_all",
    this.onViewAll,
    this.isLoading = false,
    this.showViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(
      titleKey.tr(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

    final viewAll = showViewAll
        ? GestureDetector(
            onTap: isLoading ? null : onViewAll,
            child: Text(
              viewAllKey.tr(),
              style: TextStyle(
                color: isLoading ? Colors.grey : Styles.PRIMARY_COLOR,
                fontSize: 14,
              ),
            ),
          )
        : const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [title, viewAll],
    );
  }
}
