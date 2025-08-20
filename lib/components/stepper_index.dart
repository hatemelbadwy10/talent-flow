import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:flutter/cupertino.dart';

import '../app/core/styles.dart';

class StepperIndex extends StatelessWidget {
  const StepperIndex(
      {super.key, required this.currentIndex, this.length, this.color});
  final int currentIndex;
  final int? length;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_LARGE.w,
          ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              length ?? 3,
              (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: Dimensions.PADDING_SIZE_DEFAULT.h,
                          horizontal: 4.w),
                      child: AnimatedContainer(
                        height: 3,
                        width: context.width,
                        decoration: BoxDecoration(
                            color: currentIndex >= index
                                ? color ?? Styles.PRIMARY_COLOR
                                : Styles.LIGHT_BORDER_COLOR,
                            borderRadius: BorderRadius.circular(100)),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      ),
                    ),
                  ))),
    );
  }
}
