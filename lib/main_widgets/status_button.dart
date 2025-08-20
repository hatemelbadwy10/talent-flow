import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import 'package:flutter/material.dart';

import '../app/core/styles.dart';
import '../main_models/request_status_model.dart';

class StatusButton extends StatelessWidget {
  const StatusButton(
      {super.key,
      this.status,
      this.withIcon = true,
      this.isSelect = false,
      this.onSelect});
  final StatusModel? status;
  final bool withIcon;
  final bool isSelect;
  final Function(String)? onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect?.call(status?.key ?? ""),
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isSelect
              ? Styles.PRIMARY_COLOR
              : status?.color?.toColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(100),
        ),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // if (withIcon)
            //   CustomNetworkImage.containerNewWorkImage(
            //     height: 24,
            //     width: 24,
            //     image: status?.icon ?? "",
            //   ),
            // if (withIcon) SizedBox(width: Dimensions.paddingSizeMini.w),
            Text(
              status?.key?.capitalize() ?? "",
              style: AppTextStyles.w500.copyWith(
                  fontSize: 14,
                  color:
                      isSelect ? Styles.WHITE_COLOR : status?.color?.toColor),
            ),
          ],
        ),
      ),
    );
  }
}
