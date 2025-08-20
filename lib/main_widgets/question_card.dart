import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/text_styles.dart';

import '../app/core/styles.dart';
import '../app/localization/language_constant.dart';
import '../components/dash_line_painter.dart';
import '../components/shimmer/custom_shimmer.dart';
import '../main_models/question_model.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, required this.index});
  final QuestionModel question;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$index -  ${question.title ?? "الارتقاء بمهنة الصيدلة"}",
            style:
                AppTextStyles.w600.copyWith(fontSize: 16, color: Styles.HEADER),
          ),
          SizedBox(height: 6.h),
          ReadMoreText(
            question.content ??
                "رفع مستوى مهنة الصيدلة وتطوير العلوم المتعلقة بها، بما يحقق أفضل خدمة دوائية للمواطنين.",
            style: AppTextStyles.w400
                .copyWith(fontSize: 14, color: Styles.DETAILS_COLOR),
            trimLines: 4,
            colorClickableText: Colors.pink,
            trimMode: TrimMode.Line,
            trimCollapsedText: getTranslated("show_more"),
            trimExpandedText: getTranslated("show_less"),
            textAlign: TextAlign.start,
            moreStyle: AppTextStyles.w600
                .copyWith(fontSize: 14, color: Styles.PRIMARY_COLOR),
            lessStyle: AppTextStyles.w600
                .copyWith(fontSize: 14, color: Styles.PRIMARY_COLOR),
          ),
        ],
      ),
    );
  }
}

class QuestionCardShimmer extends StatelessWidget {
  const QuestionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomShimmerText(height: 20.h, width: context.width * 0.6),
        SizedBox(height: 12.h),
        ...List.generate(
          4,
          (i) => Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: CustomShimmerText(height: 15.h, width: context.width),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: DashedLine(),
        ),
      ],
    );
  }
}
