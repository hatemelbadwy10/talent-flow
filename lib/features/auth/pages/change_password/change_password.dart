import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../app/core/app_event.dart';
import '../../../../app/core/app_state.dart';
import '../../../../components/custom_button.dart';
import '../../../../components/custom_text_form_field.dart';
import '../../../../data/config/di.dart';
import '../../widgets/auth_base.dart';
import 'bloc/change_password_bloc.dart';
import 'repo/change_password_repo.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ChangePasswordScreen({super.key, this.arguments});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordBloc(repo: sl<ChangePasswordRepo>()),
      child: AuthBase(
        children: [
          SizedBox(height: 86.h),

          Text(
            "change_password.title".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),

          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: "change_password.new_password".tr(),
                  hint: "change_password.enter_new_password".tr(),
                  isPassword: true,
                  controller: _newPasswordController,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'change_password.error_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'change_password.error_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: "change_password.confirm_password".tr(),
                  hint: "change_password.reenter_password".tr(),
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validate: (value) {
                    if (value != _newPasswordController.text) {
                      return 'change_password.error_not_match'.tr();
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          BlocBuilder<ChangePasswordBloc, AppState>(
            builder: (context, state) {
              return CustomButton(
                text: "change_password.confirm_change".tr(),
                isLoading: state is Loading,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    final String identifier = widget.arguments?["identifier"] ?? "";

                    final Map<String, dynamic> changePasswordData = {
                      "identifier": identifier,
                      "password": _newPasswordController.text,
                      "password_confirmation": _confirmPasswordController.text,
                    };

                    context.read<ChangePasswordBloc>().add(
                      Click(arguments: changePasswordData),
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