import 'package:flutter/cupertino.dart';
import '../app/core/dimensions.dart';

class GridListAnimatorWidget extends StatelessWidget {
  const GridListAnimatorWidget({
    this.aspectRatio,
    required this.items,
    this.shrinkWrap = true,
    this.columnCount,
    this.padding,
    this.controller,
    this.physics,
    super.key,
  });
  final List<Widget> items;
  final double? aspectRatio;
  final EdgeInsetsGeometry? padding;
  final int? columnCount;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: padding ?? EdgeInsets.only(top: 20.h),
      crossAxisCount: columnCount ?? 2,
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      addAutomaticKeepAlives: true,
      mainAxisSpacing: 16.h,
      childAspectRatio: aspectRatio ?? 0.9,
      crossAxisSpacing: 16.w,
      children: items,
    );
  }
}
