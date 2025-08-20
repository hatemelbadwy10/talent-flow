import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';

import '../app/core/styles.dart';
import '../app/core/svg_images.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';
import '../components/custom_images.dart';

class DeleteItemWidget extends StatelessWidget {
  const DeleteItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
      color: Styles.WHITE_COLOR,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          customContainerSvgIcon(
              imageName: SvgImages.trash,
              padding: 10,
              width: 40,
              height: 40,
              radius: 100,
              color: Styles.PRIMARY_COLOR),
          SizedBox(
            width: 8.w,
          ),
          Text(getTranslated("delete"),
              style: AppTextStyles.w500.copyWith(
                color: Styles.PRIMARY_COLOR,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
