import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/setting/model/help_model.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';

class HelpDialog extends StatefulWidget {
  final void Function(HelpModel model) onSend;

  const HelpDialog({super.key, required this.onSend});

  @override
  State<HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                "help.title".tr(),
                style: const TextStyle(
                  color: Styles.PRIMARY_COLOR,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "help.subtitle".tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Styles.HINT_COLOR,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Styles.LIGHT_BORDER_COLOR),

              const SizedBox(height: 16),

              // Form fields
              Column(
                children: [
                  CustomTextField(
                    controller: _firstNameController,
                    hint: "help.first_name".tr(),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _lastNameController,
                    hint: "help.last_name".tr(),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    hint: "help.email".tr(),
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phoneController,
                    hint: "help.phone".tr(),
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _messageController,
                    hint: "help.message".tr(),
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "help.cancel".tr(),
                      backgroundColor: Styles.ERORR_COLOR,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: "help.send".tr(),
                      backgroundColor: Styles.PRIMARY_COLOR,
                      onTap: () {
                        final model = HelpModel(
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          message: _messageController.text,
                        );
                        widget.onSend(model);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
