import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:talent_flow/app/core/dimensions.dart';

import '../../../../../app/core/app_core.dart';
import '../../../../../app/core/app_event.dart';
import '../../../../../app/core/app_notification.dart';
import '../../../../../app/core/app_state.dart';
import '../../../../../app/core/styles.dart';
import '../../../../../components/custom_button.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../bloc/social_media_bloc.dart';
class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
 return   BlocBuilder<SocialMediaBloc, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: "login.login_google".tr(),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              isLoading: state is Loading,
              lIconWidget: SvgPicture.asset("assets/svgs/google.svg"),
              onTap: () async {
                context.read<SocialMediaBloc>().add(
                  Click(arguments:SocialMediaProvider.google),
                );
              },
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: "login.login_facebook".tr(),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              lIconWidget: SvgPicture.asset("assets/svgs/facebook.svg"),
              onTap: () async {
                context.read<SocialMediaBloc>().add(
                  Click(arguments:SocialMediaProvider.facebook),
                );               },
            ),
          ],
        );
      },
    );
  }
}
