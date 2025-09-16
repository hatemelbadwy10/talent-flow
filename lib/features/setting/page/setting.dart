import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- Import the package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/images.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          Images.appLogo,
          height: 35,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'settings_screen.title'.tr(), // <-- Translated
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                _buildProfileCard(),
                const SizedBox(height: 24.0),
                _buildSettingsOptionsCard(context),
                // Pass context for language switching
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top card containing user profile information and actions.
  Widget _buildProfileCard() {
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
                CustomNavigator.push(Routes.addYourProject);
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

  /// Builds the main settings menu.
  Widget _buildSettingsOptionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
        children: [
          _buildSettingsMenuItem(
              icon: Icons.info_outline,
              text: 'settings_screen.about_talent_flow'.tr(),
              onTap: () {
                CustomNavigator.push(Routes.about);
              }),
          _buildSettingsMenuItem(
              icon: Icons.notifications_outlined,
              text: 'settings_screen.notifications'.tr(),
              onTap: () {
                CustomNavigator.push(Routes.notifications);
              }),
          _buildSettingsMenuItem(
              icon: Icons.favorite_border,
              text: 'settings_screen.favorites'.tr(),
              onTap: () {
                CustomNavigator.push(Routes.favorites);
              }),
          _buildSettingsMenuItem(
              icon: Icons.support_agent, text: 'settings_screen.support'.tr()),
          _buildSettingsMenuItem(
              icon: Icons.list_alt_outlined,
              text: 'settings_screen.terms_and_conditions'.tr(),
              onTap: () {
                CustomNavigator.push(Routes.terms);
              }),
          _buildSettingsMenuItem(
              icon: Icons.language_outlined,
              text: 'settings_screen.language'.tr(),
              secondaryText: 'settings_screen.current_language'.tr(),
              onTap: () {
                // This logic switches between English and Arabic
                Locale currentLocale = context.locale;
                if (currentLocale == const Locale('en')) {
                  context.setLocale(const Locale('ar'));
                } else {
                  context.setLocale(const Locale('en'));
                }
              }),
          const SizedBox(height: 8.0),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8.0),
          _buildSettingsMenuItem(
              icon: Icons.logout,
              text: 'settings_screen.logout'.tr(),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                CustomNavigator.push(Routes.login, clean: true);
              }),
          SizedBox(
            height: 100.h,
          )
        ],
      ),
    );
  }

  /// A helper widget to create each list item in the settings card.
  Widget _buildSettingsMenuItem(
      {required IconData icon,
      required String text,
      String? secondaryText,
      Color? textColor,
      Color? iconColor,
      void Function()? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.grey.shade600),
            const SizedBox(width: 16.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
            const Spacer(),
            if (secondaryText != null)
              Text(
                secondaryText,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
