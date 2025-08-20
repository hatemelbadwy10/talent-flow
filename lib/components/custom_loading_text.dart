import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/text_styles.dart';

import '../app/core/styles.dart';

class CustomLoadingText extends StatelessWidget {
  final bool? loading;

  const CustomLoadingText({
    super.key,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: loading ?? true,
      child: SizedBox(
          height: 50,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Loading ... ",
                  style: AppTextStyles.w400
                      .copyWith(fontSize: 12, color: Styles.DETAILS_COLOR),
                )
              ],
            ),
          )),
    );
  }
}
