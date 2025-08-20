import 'package:flutter/material.dart';
class BuildDotWidget extends StatelessWidget {
  const BuildDotWidget({super.key, required this.index, required this.currentPage});
 final int index,  currentPage;
  @override
  Widget build(buildContext,) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(left: 8),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? const Color(0xffAED4D5) : const Color(0xffDBDBDB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

}
