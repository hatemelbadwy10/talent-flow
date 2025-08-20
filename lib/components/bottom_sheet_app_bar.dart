import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';

import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class BottomSheetAppBar extends StatelessWidget {
  const BottomSheetAppBar(
      {required this.title,
      required this.textBtn,
      this.onTap,
      this.action,
      Key? key})
      : super(key: key);
  final String title, textBtn;
  final Widget? action;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              height: 5.h,
              width: 36.w,
              decoration: BoxDecoration(
                  color: const Color(0xFF3C3C43).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(100)),
              child: const SizedBox(),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          child: Row(
            children: [
              action ??
                  const SizedBox(
                    width: 50,
                  ),
              const Expanded(child: SizedBox()),
              Text(
                title,
                style: AppTextStyles.w600.copyWith(
                  fontSize: 14,
                ),
              ),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: onTap,
                child: SizedBox(
                  width: 50,
                  child: Text(
                    textBtn,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.w400
                        .copyWith(fontSize: 14, color: Styles.PRIMARY_COLOR),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            height: 1,
            width: context.width,
            color: Styles.GREY_BORDER,
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
