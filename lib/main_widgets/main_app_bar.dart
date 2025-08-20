import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/components/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:talent_flow/components/custom_images.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../app/core/text_styles.dart';
import 'guest_mode.dart';
import 'profile_image_widget.dart';
import '../navigation/routes.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key, this.withNotify = true});

  final bool withNotify;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, AppState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: Dimensions.PADDING_SIZE_DEFAULT.w,
            right: Dimensions.PADDING_SIZE_DEFAULT.w,
            top: Dimensions.PADDING_SIZE_DEFAULT.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Styles.PRIMARY_COLOR.withOpacity(0.28),
                Color(0XFFFFF6F1).withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///Profile Image Widget
                ProfileImageWidget(
                  withEdit: false,
                  radius: 24.w,
                  image: UserBloc.instance.user?.profileImage,
                ),
                SizedBox(width: 8.w),
                Expanded(
                    child: InkWell(
                  // onTap: () {
                  //   if (UserBloc.instance.isLogin) {
                  //     CustomNavigator.push(Routes.editProfile);
                  //   }
                  // },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslated("have_a_good_day", context: context)},",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.w400
                            .copyWith(fontSize: 12, color: Styles.TITLE),
                      ),
                      Text(
                        UserBloc.instance.user?.name ?? "Guest",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.w600
                            .copyWith(fontSize: 16, color: Styles.HEADER),
                      ),
                    ],
                  ),
                )),
                if (withNotify)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: customContainerSvgIcon(
                        onTap: () {
                          if (UserBloc.instance.isLogin) {
                            CustomNavigator.push(Routes.notifications);
                          } else {
                            CustomBottomSheet.show(widget: const GuestMode());
                          }
                        },
                        backGround: Styles.WHITE_COLOR,
                        color: Styles.PRIMARY_COLOR,
                        width: 40.w,
                        height: 40.w,
                        radius: 16.w,
                        padding: 10.w,
                        imageName: SvgImages.notification),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      Size(CustomNavigator.navigatorState.currentContext!.width, 70.h);
}
