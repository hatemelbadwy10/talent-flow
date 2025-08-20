
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/shimmer/custom_shimmer.dart';
import '../app/core/text_styles.dart';
import 'custom_network_image.dart';

class CustomImageStack extends StatelessWidget {
  final List<String> images;
  final Color? boarderColor;
  final double? radius;
  final bool isLoading;
  const CustomImageStack(
      {super.key,
      required this.images,
      this.boarderColor,
      this.isLoading = false,
      this.radius});

  @override
  Widget build(BuildContext context) {
    List<String> getListLength({required List<String> images}) {
      if (images.length < 4) {
        return images;
      } else {
        return images.getRange(0, 4).toList();
      }
    }

    var widgetList = images
        .sublist(0, getListLength(images: images).length)
        .asMap()
        .map(
          (index, value) => MapEntry(
              index,
              Padding(
                padding: EdgeInsets.only(left: (radius ?? 20) * index),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    isLoading
                        ? const CustomShimmerCircleImage(diameter: 50)
                        : CustomNetworkImage.circleNewWorkImage(
                            image: value,
                            radius: radius ?? 12.w,
                            color: boarderColor ?? Colors.white),
                    if (index == 3 && images.length > 4)
                      Container(
                          width: (radius ?? 12) * 2,
                          height: (radius ?? 12) * 2,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xff000000).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            "+${images.length - 3}",
                            style: AppTextStyles.w500
                                .copyWith(color: Colors.white, fontSize: 14),
                          ))
                  ],
                ),
              )),
        )
        .values
        .toList();
    return Stack(
      clipBehavior: Clip.none,
      children: widgetList,
    );
  }
}
