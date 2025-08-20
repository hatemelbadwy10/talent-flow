import 'package:flutter/material.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import '../app/localization/language_constant.dart';

class PriceCard extends StatelessWidget {
  const PriceCard({super.key, this.price,this.isFree});
  final double? price;
  final bool? isFree;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isFree != true)
          Text(
            "${price?.toStringAsFixed(1) ?? 0} ${getTranslated("kwd")}",
            style: AppTextStyles.w700
                .copyWith(fontSize: 16, color: Styles.PRIMARY_COLOR),
          )
        else
          Text(
            getTranslated("free"),
            style: AppTextStyles.w700
                .copyWith(fontSize: 16, color: Styles.PRIMARY_COLOR),
          ),
      ],
    );
  }
}
