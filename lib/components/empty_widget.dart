import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import '../app/core/images.dart';
import '../app/core/styles.dart';
import '../app/core/svg_images.dart';
import '../app/localization/language_constant.dart';
import 'custom_images.dart';

class EmptyState extends StatelessWidget {
  final String? img;
  final double? imgHeight;
  final double? emptyHeight;
  final double? imgWidth;
  final bool isSvg;
  final double? spaceBtw;
  final String? txt;
  final String? subText;
  final bool withImage;

  const EmptyState({
    super.key,
    this.emptyHeight,
    this.spaceBtw,
    this.isSvg = false,
    this.withImage = true,
    this.img,
    this.imgHeight,
    this.imgWidth,
    this.txt,
    this.subText,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50.h,
        ),
        if (withImage)
          !isSvg
              ? customImageIcon(
                  imageName: img ?? Images.emptyImage,
                  width: imgWidth ?? context.width * 0.45,
                  height: imgHeight ?? context.width * 0.45,
                ) //width: MediaQueryHelper.width*.8,),
              : customImageIconSVG(
                  imageName: img ?? SvgImages.appLogo,
                  width: imgWidth ?? context.width * 0.45,
                  height: imgHeight ?? context.height * 0.2,
                ),
        SizedBox(
          height: spaceBtw ?? 16.h,
        ),
        Text(txt ?? getTranslated("there_is_no_data"),
            textAlign: TextAlign.center,
            style: AppTextStyles.w600.copyWith(
                fontSize: 16,
                color: Styles.HEADER,
                decoration: TextDecoration.none)),
        SizedBox(height: 8.h),
        Text(subText ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                decoration: TextDecoration.none,
                color: Styles.PRIMARY_COLOR,
                fontWeight: FontWeight.w400))
      ],
    ));
  }
}
