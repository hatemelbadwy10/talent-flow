import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:talent_flow/components/custom_images.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../components/shimmer/custom_shimmer.dart';
import '../data/config/di.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.withView = false,
    this.description,
    this.onViewTap,
  });
  final String title;
  final String? description;
  final bool withView;
  final Function()? onViewTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.PADDING_SIZE_DEFAULT.w,
        bottom: Dimensions.paddingSizeExtraSmall.w,
        left: Dimensions.PADDING_SIZE_DEFAULT.w,
        right: Dimensions.PADDING_SIZE_DEFAULT.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Text(
            title,
            style:
                AppTextStyles.w600.copyWith(fontSize: 18, color: Styles.HEADER),
          )),
          if (description != null) ...[
            Text(
              description ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.w400
                  .copyWith(fontSize: 14, color: Styles.HINT_COLOR),
            ),
            SizedBox(width: 6.w),
          ],
          if (withView)
            InkWell(
              onTap: onViewTap,
              child: Row(
                children: [
                  Text(
                    getTranslated("see_all", context: context),
                    style: AppTextStyles.w600
                        .copyWith(fontSize: 14, color: Styles.PRIMARY_COLOR),
                  ),
                  // RotatedBox(
                  //   quarterTurns: sl<LanguageBloc>().isLtr ? 0 : 2,
                  //   child: customImageIconSVG(
                  //       imageName: SvgImages.arrowRight,
                  //       width: 14,
                  //       height: 14,
                  //       color: Styles.PRIMARY_COLOR),
                  // )
                ],
              ),
            )
        ],
      ),
    );
  }
}

class SectionTitleShimmer extends StatelessWidget {
  const SectionTitleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimensions.PADDING_SIZE_DEFAULT.w,
        bottom: Dimensions.paddingSizeExtraSmall.w,
        left: Dimensions.PADDING_SIZE_DEFAULT.w,
        right: Dimensions.PADDING_SIZE_DEFAULT.w,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomShimmerText(
            width: 100,
          ),
          CustomShimmerText(
            width: 70,
          ),
        ],
      ),
    );
  }
}
