// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
//
// class UploadFileService extends StatelessWidget {
//   const UploadFileService({super.key, this.onTap, required this.title});
//   final Function(String)? onTap;
//
//   final Function(String)? onGetFile;
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => ImagePickerHelper.openGallery(
//           onGet: context
//               .read<CompleteCompanyProfileBloc>()
//               .updateImage),
//       child: DottedBorder(
//         color: Styles.HINT_COLOR,
//         strokeCap: StrokeCap.square,
//         borderType: BorderType.RRect,
//         dashPattern: const [10, 10],
//         radius: const Radius.circular(15),
//         child: Container(
//             width: context.width,
//             height: 100.h,
//             decoration: BoxDecoration(
//               color: Styles.WHITE_COLOR,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Center(
//               child: snapshot.hasData
//                   ? Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.file(
//                       snapshot.data!,
//                       width: context.width,
//                       height: 100.h,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Styles.BLACK.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     width: context.width,
//                     height: 100.h,
//                     child: Column(
//                       mainAxisAlignment:
//                       MainAxisAlignment.center,
//                       children: [
//                         customImageIconSVG(
//                             imageName: SvgImages.gallery,
//                             height: 24.h,
//                             width: 24.w,
//                             color: Styles.DETAILS_COLOR),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   customImageIconSVG(
//                       imageName: SvgImages.gallery,
//                       height: 24.h,
//                       width: 24.w,
//                       color: Styles.DETAILS_COLOR),
//                   SizedBox(height: 8.h),
//                   Text(
//                     getTranslated("upload_image"),
//                     textAlign: TextAlign.center,
//                     style: AppTextStyles.w400.copyWith(
//                         fontSize: 12,
//                         color: Styles.DETAILS_COLOR),
//                   ),
//                 ],
//               ),
//             )),
//       ),
//     );
//   }
// }
