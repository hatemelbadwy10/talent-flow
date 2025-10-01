import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import '../../navigation/custom_navigation.dart';
import '../app/core/styles.dart';
import '../app/core/text_styles.dart';
import 'back_icon.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String? title;
//   final Widget? actionChild;
//   final bool withBack;
//   final bool withHPadding;
//   final bool withVPadding;
//   final double? height;
//   final Color? backColor;
//   final double? actionWidth;
//
//   const CustomAppBar(
//       {super.key,
//       this.title,
//       this.height,
//       this.backColor,
//       this.withHPadding = true,
//       this.withVPadding = true,
//       this.withBack = true,
//       this.actionWidth,
//       this.actionChild});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(
//         horizontal: withHPadding ? Dimensions.PADDING_SIZE_DEFAULT.w : 0,
//         vertical: withVPadding ? Dimensions.PADDING_SIZE_DEFAULT.h : 0,
//       ),
//       child: SafeArea(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (withBack &&
//                 CustomNavigator.navigatorState.currentState!.canPop()) ...[
//               const FilteredBackIcon(),
//               SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT.w),
//             ],
//             Expanded(
//               child: Text(
//                 title ?? "",
//                 textAlign: TextAlign.right,  // هنا تخلي النص على اليمين
//                 style: AppTextStyles.w600
//                     .copyWith(color: Styles.BORDER_COLOR, fontSize: 14),
//               ),
//             ),
//             if(actionChild != null) actionChild!,
//          SizedBox(height: 20.2,)
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => Size(
//       CustomNavigator.navigatorState.currentContext!.width, height ?? 120.h);
// }
