import 'package:talent_flow/app/core/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app/core/styles.dart';
import '../app/core/text_styles.dart';

Widget customImageIcon(
    {required String imageName,
    double? width,
    Function? onTap,
    double? height,
    BoxFit fit = BoxFit.fill,
    color}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        onTap?.call();
      },
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Image.asset(
        imageName,
        color: color,
        fit: BoxFit.fill,
        width: width ?? 30,
        height: height ?? 25,
      ),
    ),
  );
}

Widget customCircleSvgIcon(
    {String? title,
    required String imageName,
    Function? onTap,
    imageColor,
    color,
    width,
    height,
    double? radius}) {
  return InkWell(
    onTap: () {
      onTap?.call();
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color ?? Styles.PRIMARY_COLOR.withOpacity(0.1),
          radius: radius ?? 24.w,
          child: SvgPicture.asset(
            imageName,
            color: imageColor,
            width: width,
            height: height,
          ),
        ),
        Visibility(
          visible: title != null,
          child: Column(
            children: [
              SizedBox(
                height: 4.h,
              ),
              Text(
                title ?? "",
                style: AppTextStyles.w500
                    .copyWith(color: Styles.PRIMARY_COLOR, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget customContainerSvgIcon(
    {required String imageName,
    Function? onTap,
    Color? color,
    Color? backGround,
    Color? borderColor,
    bool withShadow = false,
    double? padding,
    double? width,
    double? height,
    double? radius}) {
  return InkWell(
    onTap: () {
      onTap?.call();
    },
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    child: Container(
      height: height ?? 50,
      width: width ?? 50,
      padding: EdgeInsets.all(padding ?? 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.transparent),
        color: backGround ?? Styles.PRIMARY_COLOR.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radius ?? 12),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Color(0x194B4B4B),
                  blurRadius: 10,
                  offset: Offset(0, 7),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x024B4B4B),
                  blurRadius: 10,
                  offset: Offset(0, -7),
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: SvgPicture.asset(
        imageName,
        color: color,
      ),
    ),
  );
}

Widget customContainerImage(
    {required String imageName,
    Function? onTap,
    Color? color,
    Color? backGroundColor,
    bool withShadow = false,
    double? width,
    double? height,
    double? radius}) {
  return InkWell(
    onTap: () {
      onTap!();
    },
    child: Container(
      height: height ?? 50,
      width: width ?? 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          boxShadow: withShadow
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(2, 2),
                      spreadRadius: 3,
                      blurRadius: 5)
                ]
              : null,
          color: backGroundColor ?? Styles.PRIMARY_COLOR.withOpacity(0.2),
          borderRadius: BorderRadius.circular(radius ?? 12)),
      child: Image.asset(
        imageName,
        color: color,
      ),
    ),
  );
}

Widget customImageIconSVG(
    {required String imageName,
    Color? color,
    double? height,
    double? width,
    Function()? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: SvgPicture.asset(
      imageName,
      color: color,
      height: height,
      width: width,
    ),
  );
}
