import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_bloc/send_verification_bloc.dart';
import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_state.dart';
import '../../../../app/core/dimensions.dart';
import '../../../../components/custom_button.dart';
import '../../../../components/custom_text_form_field.dart';
import '../../../../data/config/di.dart';
import '../../widgets/auth_base.dart';
import 'send_verification_repo/send_verification_repo.dart';

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
    return BlocProvider(
      create: (context) => SendVerificationBloc(
        repo: sl<SendVerificationRepo>(),
      ),
      child: AuthBase(
        children: [
          SizedBox(height: 86.h),
          Text(
            "send_verification.title".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),
          Center(
            child: SegmentedButton<VerificationType>(
              segments: <ButtonSegment<VerificationType>>[
                ButtonSegment<VerificationType>(
                  value: VerificationType.email,
                  label: Text("send_verification.email".tr()),
                  icon: const Icon(Icons.email),
                ),
                ButtonSegment<VerificationType>(
                  value: VerificationType.whatsapp,
                  label: Text("send_verification.whatsapp".tr()),
                  icon: SvgPicture.asset("assets/svgs/whatsapp.svg"),
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
                      label: "send_verification.email".tr(),
                      hint: "send_verification.enter_email".tr(),
                      controller: _emailController,
                      inputType: TextInputType.emailAddress,
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return "send_verification.error_required".tr();
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return "send_verification.error_invalid_email".tr();
                        }
                        return null;
                      },
                    )
                  : CustomTextField(
                      key: const ValueKey('whatsapp'),
                      label: "send_verification.whatsapp".tr(),
                      hint: "send_verification.enter_whatsapp".tr(),
                      controller: _phoneController,
                      inputType: TextInputType.phone,
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return "send_verification.error_required".tr();
                        }
                        if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                          return "send_verification.error_invalid_phone".tr();
                        }
                        return null;
                      },
                    ),
            ),
          ),
          const SizedBox(height: 24),

          /// -------- BlocConsumer with Button --------
          BlocConsumer<SendVerificationBloc, AppState>(
            listener: (context, state) {
              if (state is Done) {
                // navigation already handled inside bloc
              }
            },
            builder: (context, state) {
              return CustomButton(
                text: "send_verification.send".tr(),
                isLoading: state is Loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    log('clicked');
                    log('data ${_selectedVerification == VerificationType.email ? {
                        "identifier": _emailController.text
                      } : {"identifier": _phoneController.text}}');
                    final data = _selectedVerification == VerificationType.email
                        ? {"identifier": _emailController.text}
                        : {"identifier": _phoneController.text};

                    BlocProvider.of<SendVerificationBloc>(context).add(
                      Click(arguments: data),
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
        ],
      ),
    );
  }
}
