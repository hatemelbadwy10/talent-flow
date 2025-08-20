import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_button.dart';
// Make sure this path points to your custom text field file
import 'package:talent_flow/features/auth/widgets/auth_base.dart';
import '../../../app/core/styles.dart';
import '../../../app/core/text_styles.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthBase(
        children: [
          // Use a SizedBox to add some space below the logo

          Row(
            children: [
              CustomTextField(
                width: 150.w,
                label: "الاسم",
                hint: "ادخل اسمك",
                inputType: TextInputType.name,
                keyboardAction: TextInputAction.next,
                onlyBorderColor: Colors.grey,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الحقل مطلوب';
                  }
                  return null;
                },
              ),
              SizedBox(width: 8.w,),
              CustomTextField(
                width: 180.w,
                label: "اسم العائلة",
                hint: "ادخل اسم العائلة ",
                inputType: TextInputType.name,
                keyboardAction: TextInputAction.next,
                onlyBorderColor: Colors.grey,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الحقل مطلوب';
                  }
                  return null;
                },
              ),

            ],
          ),
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
              return null;
            },
          ),
          SizedBox(
            height: 12.h,
          ),
          CustomButton(
            text: "تسجيل الدخول",
            onTap: () {
              CustomNavigator.push(Routes.verification, clean: true);
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
          SizedBox(
            height: 16.h,
          ),
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
          SizedBox(
            height: 16.h,
          ),
          CustomButton(
            text: "تسجيل الدخول بواسطة جوجل",
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset(
              "assets/svgs/google.svg",
            ),
            onTap: () {},
          ),
          SizedBox(
            height: 16.h,
          ),

          CustomButton(
            text: "تسجيل الدخول بواسطة جوجل",
            backgroundColor: Colors.white,
            textColor: Colors.black,
            lIconWidget: SvgPicture.asset(
              "assets/svgs/facebook.svg",
            ),
            onTap: () {},
          ),
          SizedBox(
            height: 16.h,
          ),

          if (Platform.isIOS)
            CustomButton(
              text: "تسجيل الدخول بواسطة جوجل",
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
                text: ' لديك حساب بالفعل؟',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'تسجيل الدخول',
                    style: const TextStyle(
                      color: Styles.PRIMARY_COLOR, // اختر اللون المناسب
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // انتقل لصفحة التسجيل
                        CustomNavigator.push(Routes.login);
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