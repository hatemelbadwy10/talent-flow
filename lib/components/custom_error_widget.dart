import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/text_styles.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? error;
  const CustomErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.red,
            size: 16,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error??"",
                  style: AppTextStyles.w400
                      .copyWith(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
