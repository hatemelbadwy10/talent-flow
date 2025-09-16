import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/features/auth/pages/login/repo/login_repo.dart';
import 'package:talent_flow/helpers/social_media_login_helper.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/text_styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/auth/widgets/auth_base.dart';

import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_state.dart';
import 'bloc/login_bloc.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(repo: sl<LoginRepo>()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AuthBase(
            key: ValueKey(context.locale.languageCode),
            children: _buildLoginContent(context),
          ),

          /// Language Toggle
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLanguageButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoginContent(BuildContext context) {
    return [
      SizedBox(height: 15.h),
      Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: emailController,
              label: "login.email".tr(),
              hint: "login.email_hint".tr(),
              inputType: TextInputType.emailAddress,
              keyboardAction: TextInputAction.next,
              onlyBorderColor: Colors.grey,
              validate: (value) {
                if (value == null || value.isEmpty) {
                  return "login.email_error_required".tr();
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return "login.email_error_invalid".tr();
                }
                return null;
              },
            ),
            CustomTextField(
              controller: passwordController,
              label: "login.password".tr(),
              hint: "login.password_hint".tr(),
              isPassword: true,
              keyboardAction: TextInputAction.done,
              validate: (value) {
                if (value == null || value.isEmpty) {
                  return "login.password_error_required".tr();
                }
                if (value.length < 6) {
                  return "login.password_error_short".tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      SizedBox(height: 6.h),

      /// Forgot Password
      GestureDetector(
        onTap: () => CustomNavigator.push(Routes.verificationScreen),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            "login.forgot_password".tr(),
            style: AppTextStyles.w600.copyWith(
              color: Styles.PRIMARY_COLOR,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),

      SizedBox(height: 12.h),

      /// ✅ BlocBuilder حولين الزرار بس
      BlocBuilder<LoginBloc, AppState>(
        builder: (context, state) {
          return CustomButton(
            text: "login.title".tr(),
            isLoading: state is Loading,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                context.read<LoginBloc>().add(
                  Click(arguments: {
                    "email": emailController.text,
                    "password": passwordController.text,
                  }),
                );
              }
            },
            gradient: const LinearGradient(
              colors: [Color(0xFF031A1B), Color(0xFF0C7D81)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          );
        },
      ),

      SizedBox(height: 16.h),

      /// Divider
      Row(
        children: [
          const Expanded(child: Divider(height: 1, color: Colors.grey, thickness: 0.5, endIndent: 10)),
          Text('login.or_login_with'.tr(), style: AppTextStyles.w500.copyWith(color: Colors.grey)),
          const Expanded(child: Divider(height: 1, color: Colors.grey, thickness: 0.5, indent: 10)),
        ],
      ),

      SizedBox(height: 16.h),

      /// Social Buttons
      CustomButton(
        text: "login.login_google".tr(),
        backgroundColor: Colors.white,
        textColor: Colors.black,
        lIconWidget: SvgPicture.asset("assets/svgs/google.svg"),
        onTap: () async => await SocialMediaLoginHelper().googleLogin(),
      ),
      SizedBox(height: 16.h),
      CustomButton(
        text: "login.login_facebook".tr(),
        backgroundColor: Colors.white,
        textColor: Colors.black,
        lIconWidget: SvgPicture.asset("assets/svgs/facebook.svg"),
        onTap: () {},
      ),
      if (Platform.isIOS) ...[
        SizedBox(height: 16.h),
        CustomButton(
          text: "login.login_apple".tr(),
          backgroundColor: Colors.white,
          textColor: Colors.black,
          lIconWidget: SvgPicture.asset("assets/svgs/apple.svg"),
          onTap: () {},
        ),
      ],

      SizedBox(height: 16.h),

      /// Register
      Center(
        child: RichText(
          text: TextSpan(
            text: "login.no_account".tr(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: "login.register".tr(),
                style: const TextStyle(
                  color: Styles.PRIMARY_COLOR,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    CustomNavigator.push(Routes.freeLancer, arguments: {"from_login": true});
                  },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildLanguageButton() {
    final isArabic = context.locale.languageCode == 'ar';
    final nextLanguageText = isArabic ? 'EN' : 'عر';

    return GestureDetector(
      onTap: () async {
        final nextLocale = isArabic ? const Locale('en') : const Locale('ar');
        await context.setLocale(nextLocale);
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              nextLanguageText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
