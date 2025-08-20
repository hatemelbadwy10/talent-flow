import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/localization/language_constant.dart';

import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class CustomInfoField extends StatelessWidget {
  const CustomInfoField({super.key, required this.title, required this.value});
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeMini.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.w600.copyWith(
              fontSize: 14,
              color: Styles.HEADER,
            ),
          ),
          SizedBox(height: Dimensions.paddingSizeMini.h),
          Container(
            width: context.width,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: Styles.LIGHT_BORDER_COLOR)),
            child: Text(
              "$value ${getTranslated("kwd")}",
              style: AppTextStyles.w600.copyWith(
                fontSize: 14,
                color: Styles.DETAILS_COLOR,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
