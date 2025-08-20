import 'package:talent_flow/components/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:talent_flow/components/custom_images.dart';

import '../app/core/dimensions.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

class OpenMapOption extends StatelessWidget {
  const OpenMapOption({super.key, required this.maps, this.onMapTap});
  final List<AvailableMap> maps;
  final Function(AvailableMap map)? onMapTap;

  @override
  Widget build(BuildContext context) {
    return ListAnimator(
      customPadding:
          EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
      data: List.generate(
        maps.length,
        (index) => InkWell(
          onTap: () => onMapTap!(maps[index]),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall.h,
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(
                color: Styles.LIGHT_BORDER_COLOR,
              ),
            )),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: customCircleSvgIcon(
                    imageName: maps[index].icon,
                    height: 40.0,
                    width: 40.0,
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: Text(
                    maps[index].mapName,
                    style: AppTextStyles.w600
                        .copyWith(color: Styles.HEADER, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
