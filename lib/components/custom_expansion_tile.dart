import 'package:talent_flow/app/core/dimensions.dart';
import 'package:flutter/material.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class CustomExpansionTile extends StatelessWidget {
  const CustomExpansionTile(
      {required this.title,
      required this.children,
      this.childrenPadding,
      this.iconColor,
      this.titleColor,
      super.key,
      this.leading});
  final String title;
  final List<Widget> children;
  final double? childrenPadding;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: AppTextStyles.w600
            .copyWith(fontSize: 16, color: titleColor ?? Styles.HEADER),
      ),
      leading: leading,
      minTileHeight: 0,
      tilePadding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall.w,
          vertical: Dimensions.paddingSizeMini.h),
      childrenPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall.w,
          vertical: Dimensions.paddingSizeMini.h),
      collapsedIconColor: iconColor ?? Styles.HEADER,
      initiallyExpanded: true,
      iconColor: iconColor ?? Styles.HEADER,
      backgroundColor: Styles.SMOKED_WHITE_COLOR,
      collapsedBackgroundColor: Styles.SMOKED_WHITE_COLOR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
