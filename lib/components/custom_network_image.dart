import 'package:talent_flow/app/core/dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../app/core/images.dart';
import '../app/core/styles.dart';
import 'image_pop_up_viewer.dart';
import 'lottie_file.dart';

class CustomNetworkImage {
  static CustomNetworkImage? _instance;

  CustomNetworkImage._internal();

  factory CustomNetworkImage() {
    _instance ??= CustomNetworkImage._internal();
    return _instance!;
  }

  ///Container Network Image with border
  static Widget containerNewWorkImage(
      {String image = "",
      double? radius,
      String? defaultImage,
      EdgeInsetsGeometry? padding,
      double? height,
      double? width,
      BoxFit? fit,
      Color? borderColor,
      double? widthOfShimmer,
      Widget? imageWidget,
      Function()? onTap,
      bool topEdges = false}) {
    return CachedNetworkImage(
      imageUrl: image,
      fadeInDuration: const Duration(seconds: 1),
      fadeOutDuration: const Duration(seconds: 2),
      errorWidget: (a, b, c) => Container(
          width: width ?? 40.w,
          height: height ?? 40.h,
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.transparent),
            borderRadius: topEdges
                ? BorderRadius.only(
                    topRight: Radius.circular(radius ?? 12),
                    topLeft: Radius.circular(radius ?? 12))
                : BorderRadius.circular(radius ?? 12),
            color: Styles.WHITE_COLOR,
            image: DecorationImage(
                fit: fit ?? BoxFit.contain,
                image: AssetImage(
                  defaultImage ?? Images.appLogo,
                )),
          ),
          child: imageWidget),
      placeholder: (context, url) => ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? 10),
          child: Container(
              width: width ?? 40.w,
              height: height ?? 40.h,
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor ?? Colors.transparent),
                  borderRadius: topEdges
                      ? BorderRadius.only(
                          topRight: Radius.circular(radius ?? 10),
                          topLeft: Radius.circular(radius ?? 10))
                      : BorderRadius.all(Radius.circular(radius ?? 10.0)),
                  color: Styles.GREY_BORDER),
              child: LottieFile.asset("image_loading", height: height))),
      imageBuilder: (context, provider) {
        return GestureDetector(
          onTap: () {
            if (onTap == null) {
              showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.75),
                  builder: (context) {
                    return ImagePopUpViewer(
                      image: image,
                      isFromInternet: true,
                      title: "",
                    );
                  });
            } else {
              onTap.call();
            }
          },
          child: Container(
            width: width ?? 40.w,
            height: height ?? 40.h,
            padding: padding,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.transparent),
              borderRadius: topEdges
                  ? BorderRadius.only(
                      topRight: Radius.circular(radius ?? 10),
                      topLeft: Radius.circular(radius ?? 10))
                  : BorderRadius.all(Radius.circular(radius ?? 10.0)),
              image: DecorationImage(fit: fit ?? BoxFit.cover, image: provider),
            ),
            child: imageWidget,
          ),
        );
      },
    );
  }

  /// Circle Network Image
  static Widget circleNewWorkImage(
      {String? image,
      required double radius,
      String? defaultImage,
      bool isDefaultSvg = true,
      Function()? onTap,
      backGroundColor,
      color,
      double? padding}) {
    return CachedNetworkImage(
      imageUrl: (image ?? ""),
      repeat: ImageRepeat.noRepeat,
      errorWidget: (a, c, b) => Container(
        height: radius * 2,
        width: radius * 2,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: backGroundColor ?? Colors.white,
            border: color != null ? Border.all(color: color, width: 1) : null,
            shape: BoxShape.circle),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: backGroundColor ?? Colors.white,
          child: Image.asset(
            Images.appLogo,
            fit: BoxFit.cover,
          ),
        ),
      ),
      fadeInDuration: const Duration(seconds: 1),
      fadeOutDuration: const Duration(seconds: 2),
      placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: Styles.GREY_BORDER,
          child: LottieFile.asset(
            "image_loading",
            height: radius * 2,
          )),
      imageBuilder: (context, provider) {
        return GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap.call();
            } else {
              showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.75),
                  builder: (context) {
                    return ImagePopUpViewer(
                      image: image,
                      isFromInternet: true,
                      title: "",
                    );
                  });
            }
          },
          child: Container(
            height: radius * 2,
            width: radius * 2,
            padding: EdgeInsets.all(padding ?? 0),
            decoration:
                BoxDecoration(color: backGroundColor, shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundImage: provider,
              radius: radius,
              backgroundColor: backGroundColor ?? Colors.white,
            ),
          ),
        );
      },
    );
  }
}
