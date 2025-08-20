import 'package:flutter/material.dart';

import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import 'custom_images.dart';

class CustomRadioButton extends StatelessWidget {
  final void Function(bool)? onChange;
  final bool check;
  final String title;
  final String? icon;

  const CustomRadioButton(
      {super.key,
      required this.check,
      this.onChange,
      required this.title,
      this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        if (onChange != null) onChange!(!check);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL.h),
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
            vertical: Dimensions.PADDING_SIZE_SMALL.h),
        decoration: BoxDecoration(
          color: check
              ? Styles.PRIMARY_COLOR.withOpacity(0.2)
              : Styles.FILL_COLOR,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: Styles.PRIMARY_COLOR),
        ),
        child: Row(
          children: [
            Visibility(
              visible: icon != null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: customImageIcon(
                  imageName: icon ?? "",
                  height: 18.h,
                  width: 24.w,
                ),
              ),
            ),
            Visibility(visible: icon != null, child: SizedBox(width: 16.w)),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.w600.copyWith(
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  color: Styles.PRIMARY_COLOR,
                ),
              ),
            ),
            check
                ? Container(
                    padding: const EdgeInsets.all(2),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        color: Styles.WHITE_COLOR,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Styles.PRIMARY_COLOR, width: 1)),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.PRIMARY_COLOR,
                      ),
                    ),
                  )
                : Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Styles.PRIMARY_COLOR, width: 1)),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.WHITE_COLOR,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
