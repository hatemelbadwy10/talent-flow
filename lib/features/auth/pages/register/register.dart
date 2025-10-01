import 'dart:developer';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/features/auth/pages/register/repo/register_repo.dart';
import 'package:talent_flow/features/auth/widgets/auth_base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/core/app_core.dart';
import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_notification.dart';
import '../../../../app/core/app_state.dart';
import '../../../../app/core/app_storage_keys.dart';
import '../../../../app/core/styles.dart';
import '../../../../app/core/text_styles.dart';
import '../../../../components/custom_text_form_field.dart';
import '../../../../helpers/social_media_login_helper.dart';
import '../../../../navigation/custom_navigation.dart';
import '../../../../navigation/routes.dart';
import '../../../../data/config/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/bloc/login_bloc.dart';
import '../social_media_login/bloc/social_media_bloc.dart';
import 'bloc/register_bloc.dart'; // Import Bloc

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;
    final String userType = isFreelancer
        ? "Freelancer"
        : "Entrepreneur"; // Determine user type

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterBloc(repo: sl<RegisterRepo>()),
        ),
        BlocProvider(
          create: (context) => SocialMediaBloc(repo: sl()),
        ),
      ],
      child: AuthBase(
        children: [
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  isFreelancer ? Icons.work : Icons.search,
                  size: 64,
                  color: Styles.PRIMARY_COLOR,
                ),
                SizedBox(height: 16.h),
                Text(
                  isFreelancer
                      ? "register.register_as_freelancer".tr()
                      : "register.register_as_user".tr(),
                  style: AppTextStyles.w700.copyWith(
                    fontSize: 20,
                    color: Styles.PRIMARY_COLOR,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          /// --------- Form for registration fields ---------
          Form(
            key: _formKey,
            child: Column(
              children: [

                /// --------- First & Last name fields ---------
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: "register.first_name".tr(),
                        hint: "register.enter_first_name".tr(),
                        inputType: TextInputType.name,
                        keyboardAction: TextInputAction.next,
                        onlyBorderColor: Colors.grey,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'register.field_required'.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: "register.last_name".tr(),
                        hint: "register.enter_last_name".tr(),
                        inputType: TextInputType.name,
                        keyboardAction: TextInputAction.next,
                        onlyBorderColor: Colors.grey,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'register.field_required'.tr();
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                /// --------- Email field ---------
                CustomTextField(
                  controller: _emailController,
                  label: "register.email".tr(),
                  hint: "register.enter_email".tr(),
                  inputType: TextInputType.emailAddress,
                  keyboardAction: TextInputAction.next,
                  onlyBorderColor: Colors.grey,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.field_required'.tr();
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'register.enter_valid_email'.tr();
                    }
                    return null;
                  },
                ),

                /// --------- Password field ---------
                CustomTextField(
                  controller: _passwordController,
                  label: "register.password".tr(),
                  hint: "register.enter_password".tr(),
                  isPassword: true,
                  keyboardAction: TextInputAction.done,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register.field_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'register.password_min_length'.tr();
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          /// --------- Register button ---------
          SizedBox(height: 12.h),
          BlocConsumer<RegisterBloc, AppState>(
            listener: (context, state) {
              if (state is Done) {}
            },
            builder: (context, state) {
              return CustomButton(
                isLoading: state is Loading,
                text: "register.register_button".tr(),
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    log("usertype ${userType}");
                    BlocProvider.of<RegisterBloc>(context).add(
                      Click(
                        arguments: {
                          "first_name": _firstNameController.text,
                          "last_name": _lastNameController.text,
                          "email": _emailController.text,
                          "password": _passwordController.text,
                          "user_type": userType,
                        },
                      ),
                    );
                  }
                },
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF031A1B),
                    Color(0xFF0C7D81),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              );
            },
          ),

          /// --------- OR divider ---------
          SizedBox(height: 16.h),
          Row(
            children: [
              const Expanded(
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 0.5,
                  endIndent: 10,
                ),
              ),
              Text(
                'register.or_register_with'.tr(),
                style: AppTextStyles.w500.copyWith(color: Colors.grey),
              ),
              const Expanded(
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 0.5,
                  indent: 10,
                ),
              ),
            ],
          ),

          /// --------- Social buttons ---------
          SizedBox(height: 16.h),
          CustomButton(
            text: "register.register_google".tr(),
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset("assets/svgs/google.svg"),
            onTap: () async {
              final result = await SocialMediaLoginHelper().googleLogin();

              result.fold(
                    (failure) {
                  // show error
                  AppCore.showSnackBar(
                    notification: AppNotification(
                      message: failure.error,
                      backgroundColor: Styles.IN_ACTIVE,
                    ),
                  );
                },
                    (socialModel) {
                  // call bloc event
                  context.read<RegisterBloc>().add(
                    SocialLoginClick(
                      provider: socialModel.provider!, // "google"
                      token: socialModel.idToken!,
                      userType: userType,
// the token for backend
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 16.h),
          CustomButton(
            text: "register.register_facebook".tr(),
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset("assets/svgs/facebook.svg"),
            onTap: () {},
          ),
          SizedBox(height: 16.h),
          if (Platform.isIOS)
            CustomButton(
              text: "register.register_apple".tr(),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              lIconWidget: SvgPicture.asset("assets/svgs/apple.svg"),
              onTap: () {},
            ),

          SizedBox(height: 16.h),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'register.already_have_account'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'register.login'.tr(),
                    style: const TextStyle(
                      color: Styles.PRIMARY_COLOR,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        CustomNavigator.push(Routes.login);
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}