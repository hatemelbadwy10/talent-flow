import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../components/custom_button.dart';

import '../../../components/custom_text_form_field.dart';
import '../../../navigation/routes.dart';
import '../widgets/auth_base.dart';
class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthBase(
        children: [
          SizedBox(height: 86.h,),

          const Text(
            "تغيير كلمة المرور",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),

          Form(
            key: _formKey,
            child: Column(
              children: [

                CustomTextField(
                  label: "كلمة المرور الجديدة",
                  hint: "ادخل كلمة المرور الجديدة",
                  isPassword: true,
                  controller: _newPasswordController,
                  validate: (value) {
                    if (value == null || value.isEmpty) return 'الحقل مطلوب';
                    if (value.length < 6) return 'كلمة المرور قصيرة جداً';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: "تأكيد كلمة المرور",
                  hint: "اعد كتابة كلمة المرور",
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validate: (value) {
                    if (value != _newPasswordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          CustomButton(

            text: "تأكيد التغيير",
            onTap: () {
              if (_formKey.currentState!.validate()) {
                CustomNavigator.push(Routes.login, clean: true);
                // Change password
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
        ],
      ),
    );
  }
}
