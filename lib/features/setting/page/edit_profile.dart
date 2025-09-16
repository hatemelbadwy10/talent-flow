import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/images.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../data/config/di.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          Images.appLogo ?? "",
          height: 35,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                "edit_profile.title".tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const EditProfileForm(),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _detailedBioController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _detailedBioController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildNameFields(),
          _buildLabeledTextField(
            "edit_profile.email".tr(),
            sl<SharedPreferences>().getString(AppStorageKey.userEmail) ?? "edit_profile.email_hint".tr(),
            _emailController,
          ),
          _buildDropdownField(
            "edit_profile.specialization".tr(),
            "edit_profile.specialization_hint".tr(),
          ),
          _buildDropdownField(
            "edit_profile.job_title".tr(),
            "edit_profile.job_title_hint".tr(),
          ),
          _buildLabeledTextField(
            "edit_profile.bio".tr(),
            "edit_profile.bio_hint".tr(),
            _bioController,
            maxLines: 4,
          ),
          _buildLabeledTextField(
            "edit_profile.detailed_bio".tr(),
            "",
            _detailedBioController,
            maxLines: 4,
          ),
          _buildDropdownField(
            "edit_profile.skills".tr(),
            "edit_profile.skills_hint".tr(),
          ),
          _buildLabeledTextField(
            "edit_profile.new_password".tr(),
            "edit_profile.password_hint".tr(),
            _newPasswordController,
            obscureText: true,
          ),
          _buildLabeledTextField(
            "edit_profile.confirm_password".tr(),
            "edit_profile.password_hint".tr(),
            _confirmPasswordController,
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "edit_profile.change_password".tr(),
                style: const TextStyle(color: Color(0xFF00C4A1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onTap: () {
              print("Save button pressed!");
            },
            text: "edit_profile.save".tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCEE5E6),
      ),
      child: Column(
        children: [
          SizedBox(height: 43.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.0),
                  image:  DecorationImage(
                    image: NetworkImage(
                        sl<SharedPreferences>().getString(AppStorageKey.userImage) ?? Images.appLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: const Icon(
                    Icons.edit,
                    color: Styles.PRIMARY_COLOR,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.grey)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLabeledTextField(
            "edit_profile.first_name".tr(),
            sl<SharedPreferences>().getString(AppStorageKey.userName) ?? "edit_profile.first_name_hint".tr(),
            _firstNameController,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLabeledTextField(
            "edit_profile.last_name".tr(),
            "edit_profile.last_name_hint".tr(),
            _lastNameController,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledTextField(
      String label,
      String hint,
      TextEditingController controller, {
        int maxLines = 1,
        bool obscureText = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black),
              children: const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: controller,
            hint: hint,
            maxLines: maxLines,
            obscureText: obscureText,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black),
              children: const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hintText, style: TextStyle(color: Colors.grey.shade600)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
