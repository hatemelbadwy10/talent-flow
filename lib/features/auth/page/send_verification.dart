import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/svg_images.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../navigation/routes.dart';
import '../widgets/auth_base.dart';

enum VerificationType { email, whatsapp }

class SendVerificationScreen extends StatefulWidget {
  const SendVerificationScreen({super.key});

  @override
  State<SendVerificationScreen> createState() => _SendVerificationScreenState();
}

class _SendVerificationScreenState extends State<SendVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  VerificationType _selectedVerification = VerificationType.email;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthBase(
        children: [
          SizedBox(height: 86.h),
          const Text(
            "ارسل تعليمات تأكيد الحساب",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),
          Center(
            child: SegmentedButton<VerificationType>(
              segments:  <ButtonSegment<VerificationType>>[
                ButtonSegment<VerificationType>(
                  value: VerificationType.email,
                  label: Text('البريد الالكتروني'),
                  icon: Icon(Icons.email),
                ),
                ButtonSegment<VerificationType>(
                  value: VerificationType.whatsapp,
                  label: Text('رقم الواتساب'),
                  icon: SvgPicture.asset(SvgImages.whatsApp), // Corrected Icon
                ),
              ],
              selected: <VerificationType>{_selectedVerification},
              onSelectionChanged: (Set<VerificationType> newSelection) {
                setState(() {
                  _selectedVerification = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: const Color(0xFF0C7D81),
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: const Color(0xFF0C7D81),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _selectedVerification == VerificationType.email
                  ? CustomTextField(
                key: const ValueKey('email'),
                label: "البريد الالكتروني",
                hint: "ادخل البريد الالكتروني الخاص بك",
                controller: _emailController,
                inputType: TextInputType.emailAddress,
                validate: (value) {
                  if (value == null || value.isEmpty) return 'الحقل مطلوب';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'الرجاء إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              )
                  : CustomTextField(
                key: const ValueKey('whatsapp'),
                label: "رقم الواتساب",
                hint: "ادخل رقم الواتساب الخاص بك",
                controller: _phoneController,
                inputType: TextInputType.phone,
                validate: (value) {
                  if (value == null || value.isEmpty) return 'الحقل مطلوب';
                  if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                    return 'الرجاء إدخال رقم هاتف صحيح';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "إرسال",
            onTap: () {
              if (_formKey.currentState!.validate()) {
                CustomNavigator.push(Routes.sendCodeScreen);
                // Send email or WhatsApp instructions based on _selectedVerification
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