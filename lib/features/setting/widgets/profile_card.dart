import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';

import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/images.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        // Use .start for proper LTR/RTL alignment
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(sl<SharedPreferences>()
                    .getString(AppStorageKey.userImage) ??
                    Images.appLogo),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sl<SharedPreferences>().getString(AppStorageKey.userName) ??
                        "user_example.name".tr(), // <-- Translated
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    sl<SharedPreferences>()
                        .getString(AppStorageKey.userEmail) ??
                        "user_example.email".tr(),
                    // <-- Translated
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8.0),
          _buildProfileOption(
              icon: Icons.edit_outlined,
              text: 'settings_screen.edit_profile'.tr(), // <-- Translated
              onTap: () {
                CustomNavigator.push(Routes.editProfile);
              }),
          _buildProfileOption(
              icon: Icons.file_upload_outlined,
              text: 'settings_screen.upload_work'.tr(), // <-- Translated
              onTap: () {
                CustomNavigator.push(sl<SharedPreferences>()
                    .getBool(AppStorageKey.isFreelancer) ??
                    true
                    ? Routes.addYourProject
                    : Routes.addProject);
              }),
        ],
      ),
    );
  }
  Widget _buildProfileOption(
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 22),
            SizedBox(width: 8.w),
            Text(text, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

}
