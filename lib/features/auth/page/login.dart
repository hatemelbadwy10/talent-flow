import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_button.dart';
import '../../../app/core/styles.dart';
import '../../../app/core/text_styles.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import 'package:talent_flow/features/auth/widgets/auth_base.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  // 1. Create a GlobalKey for the Form
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthBase(
        children: [
          SizedBox(height:15.h),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Use a SizedBox to add some space below the logo

                CustomTextField(
                  label: "البريد الالكتروني",
                  hint: "ادخل البريد الالكتروني الخاص بك",
                  inputType: TextInputType.emailAddress,
                  keyboardAction: TextInputAction.next,
                  onlyBorderColor: Colors.grey,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الحقل مطلوب';
                    }
                    // Optional: Add more specific email validation
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  label: "كلمة المرور",
                  hint: "ادخل كلمة المرور الخاصة بك",
                  isPassword: true, // This enables the hide/show password icon
                  keyboardAction: TextInputAction.done,
                  // Providing a validation function will automatically show the red '*'
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الحقل مطلوب';
                    }
                    if (value.length < 6) {
                      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () {
              CustomNavigator.push(Routes.verificationScreen);
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "نسيت كلمة المرور؟",
                style: AppTextStyles.w600.copyWith(
                  color: Styles.PRIMARY_COLOR,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h,),
          CustomButton(
            text: "تسجيل الدخول",
            onTap: () {
              if (_formKey.currentState!.validate()) {
                CustomNavigator.push(Routes.navBar, clean: true);
                sl<SharedPreferences>().setBool(AppStorageKey.isLogin, true);
              }
            },
            gradient: const LinearGradient(
              colors: [
                Color(0xFF031A1B), // Right
                Color(0xFF0C7D81), // Left
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          SizedBox(height: 16.h,),
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
                'أو تسجيل الدخول ب',
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
          SizedBox(height: 16.h,),
          CustomButton(
            text: "تسجيل الدخول بواسطة جوجل",
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset(
              "assets/svgs/google.svg",
            ),
            onTap: () {},
          ),
          SizedBox(height: 16.h,),

          CustomButton(
            text: "تسجيل الدخول بواسطة فيسبوك", // Changed text for clarity
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset(
              "assets/svgs/facebook.svg",
            ),
            onTap: () {},
          ),
          SizedBox(height: 16.h,),

          if(Platform.isIOS)
            CustomButton(
              text: "تسجيل الدخول بواسطة آبل", // Changed text for clarity
              backgroundColor: Colors.white,
              textColor: Colors.black,
              lIconWidget: SvgPicture.asset(
                "assets/svgs/apple.svg",
              ),
              onTap: () {},
            ),
          SizedBox(height: 16.h),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'لا تملك حساب؟ ',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'تسجيل جديد',
                    style: const TextStyle(
                      color:Styles.PRIMARY_COLOR, // اختر اللون المناسب
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // انتقل لصفحة التسجيل
                        CustomNavigator.push(Routes.register);
                      },
                  ),
                ],
              ),
            ),
          ),

          // Example:
          // ElevatedButton(onPressed: () {}, child: const Text("تسجيل الدخول")),
        ],
      ),
    );
  }
}