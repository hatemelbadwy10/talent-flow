import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/svg_images.dart';
import '../navigation/custom_navigation.dart';
import 'custom_images.dart';

class FilteredBackIcon extends StatelessWidget {
  const FilteredBackIcon({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 2,
      child: customContainerSvgIcon(
        onTap: () {
          CustomNavigator.pop();
        },
        imageName: SvgImages.backArrow,
        width: 35.w,
        height: 35.w,
        padding: 9.w,
        radius: 12.w,
        withShadow: false,
        backGround: Styles.PRIMARY_COLOR.withOpacity(0.1),
        // borderColor: Styles.PRIMARY_COLOR.withOpacity(0.1),
        color: Styles.PRIMARY_COLOR,
      ),
    );
  }
}
