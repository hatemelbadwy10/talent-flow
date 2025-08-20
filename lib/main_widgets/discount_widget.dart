// import 'package:flutter/material.dart';
// import 'package:talent_flow/app/core/dimensions.dart';
// import 'package:talent_flow/app/core/text_styles.dart';
//
// import '../app/core/images.dart';
// import '../app/core/styles.dart';
// import '../data/config/di.dart';
//
// class DiscountWidget extends StatelessWidget {
//   const DiscountWidget({super.key, this.discount});
//   final double? discount;
//   @override
//   Widget build(BuildContext context) {
//     return Transform.flip(
//       flipX: !sl<LanguageBloc>().isLtr,
//       child: Container(
//         width: 55.w,
//         height: 65.w,
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(20.w),
//           ),
//           image: DecorationImage(
//             image: AssetImage(Images.discount),
//             fit: BoxFit.contain,
//           ),
//         ),
//         child: Transform.flip(
//           flipX: !sl<LanguageBloc>().isLtr,
//           child: Transform.rotate(
//             angle: sl<LanguageBloc>().isLtr ? 0.85 : -0.85,
//             child: Text(
//               "- ${discount ?? "10"} %",
//               textAlign: TextAlign.center,
//               style: AppTextStyles.w500
//                   .copyWith(fontSize: 10, height: 1, color: Styles.WHITE_COLOR),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
