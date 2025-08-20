// import 'package:talent_flow/app/core/app_core.dart';
// import 'package:talent_flow/app/core/app_state.dart';
// import 'package:talent_flow/app/core/dimensions.dart';
// import 'package:talent_flow/navigation/custom_navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../../app/core/app_notification.dart';
// import '../../../../../app/core/styles.dart';
// import '../../../../../app/core/svg_images.dart';
// import '../../../../../app/core/text_styles.dart';
// import '../../../../../app/localization/language_constant.dart';
// import '../../../../../components/custom_bottom_sheet.dart';
// import '../../../../../components/custom_images.dart';
// import 'package:country_state_city/models/state.dart' as states_of_country;
// import 'package:talent_flow/components/animated_widget.dart';
// import 'package:talent_flow/app/core/extensions.dart';
//
// class StatesOfCountrySelection extends StatelessWidget {
//   const StatesOfCountrySelection(
//       {super.key, this.onSelect, this.initialSelection});
//   final Function(String)? onSelect;
//   final String? initialSelection;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CountriesBloc, AppState>(
//       builder: (context, state) {
//         return Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 getTranslated("state"),
//                 style: AppTextStyles.w600
//                     .copyWith(fontSize: 14, color: Styles.HEADER),
//               ),
//               SizedBox(height: 8.h),
//               GestureDetector(
//                 onTap: () {
//                   if (state is Done) {
//                     List<states_of_country.State> list =
//                         state.data as List<states_of_country.State>;
//                     CustomBottomSheet.show(
//                       label: getTranslated("select_your_state"),
//                       onConfirm: () => CustomNavigator.pop(),
//                       widget: _SelectionView(
//                         list: list,
//                         initialValue: initialSelection,
//                         onConfirm: (v) => onSelect?.call(v),
//                       ),
//                     );
//                   }
//                   if (state is Start) {
//                     AppCore.showSnackBar(
//                         notification: AppNotification(
//                       message: getTranslated("oops_please_select_your_country"),
//                       backgroundColor: Styles.PENDING,
//                     ));
//                   }
//                   if (state is Loading) {
//                     AppCore.showSnackBar(
//                         notification: AppNotification(
//                       message: getTranslated("loading"),
//                       backgroundColor: Styles.PENDING,
//                     ));
//                   }
//                   if (state is Empty) {
//                     AppCore.showSnackBar(
//                         notification: AppNotification(
//                       message: getTranslated("something_went_wrong"),
//                       backgroundColor: Styles.PENDING,
//                     ));
//                   }
//                   if (state is Error) {
//                     AppCore.showSnackBar(
//                         notification: AppNotification(
//                       message: getTranslated("there_is_no_state"),
//                       backgroundColor: Styles.PENDING,
//                     ));
//                   }
//                 },
//                 child: Container(
//                   height: 48.h,
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Styles.LIGHT_BORDER_COLOR,
//                     ),
//                     borderRadius: BorderRadius.circular(12.w),
//                   ),
//                   child: Row(
//                     children: [
//                       customImageIconSVG(
//                         imageName: SvgImages.state,
//                         color: Styles.HINT_COLOR,
//                         height: 16.h,
//                         width: 16.w,
//                       ),
//                       Container(
//                         height: 100,
//                         width: 1,
//                         margin: EdgeInsets.symmetric(horizontal: 14.w),
//                         decoration: BoxDecoration(
//                             color: Styles.HINT_COLOR,
//                             borderRadius: BorderRadius.circular(100)),
//                         child: const SizedBox(),
//                       ),
//                       Expanded(
//                         child: Text(
//                           initialSelection ??
//                               getTranslated("select_your_state"),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: AppTextStyles.w400.copyWith(
//                               fontSize: 14,
//                               color: initialSelection != null
//                                   ? Styles.HEADER
//                                   : Styles.HINT_COLOR),
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _SelectionView extends StatefulWidget {
//   const _SelectionView(
//       {required this.onConfirm, required this.list, this.initialValue});
//   final ValueChanged<String> onConfirm;
//   final List<states_of_country.State> list;
//   final String? initialValue;
//
//   @override
//   State<_SelectionView> createState() => _SelectionViewState();
// }
//
// class _SelectionViewState extends State<_SelectionView> {
//   String? _selectedItem;
//   @override
//   void initState() {
//     setState(() {
//       if (widget.initialValue != null) {
//         _selectedItem = widget.initialValue;
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListAnimator(
//       controller: ScrollController(),
//       customPadding:
//           EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT.w),
//       data: List.generate(
//         widget.list.length,
//         (index) => GestureDetector(
//           onTap: () {
//             setState(() => _selectedItem = widget.list[index].name);
//             widget.onConfirm(widget.list[index].name);
//           },
//           child: Container(
//             margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL.h),
//             padding: EdgeInsets.symmetric(
//                 horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
//                 vertical: Dimensions.PADDING_SIZE_SMALL.h),
//             decoration: BoxDecoration(
//               color: _selectedItem == widget.list[index].name
//                   ? Styles.PRIMARY_COLOR
//                   : Styles.WHITE_COLOR,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                   color: _selectedItem == widget.list[index].name
//                       ? Styles.WHITE_COLOR
//                       : Styles.PRIMARY_COLOR),
//             ),
//             width: context.width,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.list[index].name,
//                     style: AppTextStyles.w600.copyWith(
//                       fontSize: 16,
//                       overflow: TextOverflow.ellipsis,
//                       color: _selectedItem == widget.list[index].name
//                           ? Styles.WHITE_COLOR
//                           : Styles.PRIMARY_COLOR,
//                     ),
//                   ),
//                 ),
//                 Icon(
//                     _selectedItem == widget.list[index].name
//                         ? Icons.radio_button_checked_outlined
//                         : Icons.radio_button_off,
//                     size: 22,
//                     color: _selectedItem == widget.list[index].name
//                         ? Styles.WHITE_COLOR
//                         : Styles.PRIMARY_COLOR)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
