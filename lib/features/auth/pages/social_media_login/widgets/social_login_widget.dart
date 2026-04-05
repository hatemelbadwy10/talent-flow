import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:talent_flow/app/core/dimensions.dart';

import '../../../../../components/custom_button.dart';
import '../../../../../helpers/social_media_login_helper.dart';
import '../bloc/social_media_bloc.dart';
import '../bloc/social_media_event.dart';
import '../bloc/social_media_state.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialMediaBloc, SocialMediaState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: "login.login_google".tr(),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              isLoading: state is SocialMediaInProgress,
              lIconWidget: SvgPicture.asset("assets/svgs/google.svg"),
              onTap: () async {
                context.read<SocialMediaBloc>().add(
                      const SocialProviderAuthenticationRequested(
                        SocialMediaProvider.google,
                      ),
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
                      const SocialProviderAuthenticationRequested(
                        SocialMediaProvider.facebook,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
