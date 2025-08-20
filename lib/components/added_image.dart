// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:talent_flow/app/core/dimensions.dart';
// import 'package:talent_flow/app/core/extensions.dart';
//
// import '../app/core/app_event.dart';
// import '../app/core/app_state.dart';
// import '../app/core/styles.dart';
// import '../app/core/text_styles.dart';
// import 'custom_network_image.dart';
// import 'custom_simple_dialog.dart';
//
// class ImageWidget extends StatelessWidget {
//   const ImageWidget({super.key, this.image, this.onDelete});
//
//   final AttachmentModel? image;
//   final Function()? onDelete;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w),
//       child: SizedBox(
//         width: context.width / 4,
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               spacing: 4.h,
//               children: [
//                 image?.file != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(12.w),
//                         child: Image.file(
//                           image!.file!,
//                           width: context.width / 4,
//                           height: 100.h,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : CustomNetworkImage.containerNewWorkImage(
//                         image: image?.image ?? "",
//                         height: 100.h,
//                         width: context.width / 4,
//                         radius: 12.w,
//                       ),
//                 if (image?.name != null || image?.type?.name != null)
//                   Text(
//                     image?.name ?? image?.type?.name ?? "",
//                     textAlign: TextAlign.center,
//                     style: AppTextStyles.w400.copyWith(
//                       fontSize: 14,
//                       color: Styles.TITLE,
//                     ),
//                   ),
//               ],
//             ),
//             Positioned(
//               top: 5.h,
//               // right: sl<LanguageBloc>().isLtr ? 5.w : null,
//               // left: sl<LanguageBloc>().isLtr ? null : 5.w,
//               child: GestureDetector(
//                 onTap: () {
//                   if (image?.image != null) {
//                     CustomSimpleDialog.parentSimpleDialog(
//                       customWidget: BlocProvider(
//                         create: (context) =>
//                             DeleteFileBloc(repo: sl<DeleteFileRepo>()),
//                         child: BlocBuilder<DeleteFileBloc, AppState>(
//                             builder: (context, state) {
//                           return DeleteItem(
//                             id: image?.id ?? 0,
//                             isLoading: state is Loading,
//                             onTap: () => context.read<DeleteFileBloc>().add(
//                                   Click(
//                                     arguments: {
//                                       "id": image?.id,
//                                       "onDone": () => onDelete?.call()
//                                     },
//                                   ),
//                                 ),
//                           );
//                         }),
//                       ),
//                     );
//                   } else {
//                     onDelete?.call();
//                   }
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(3.w),
//                   decoration: const BoxDecoration(
//                       color: Styles.IN_ACTIVE, shape: BoxShape.circle),
//                   child: const Icon(
//                     Icons.close,
//                     color: Styles.WHITE_COLOR,
//                     size: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
