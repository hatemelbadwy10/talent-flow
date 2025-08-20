import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/images.dart';
import '../../../components/custom_app_bar.dart';
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
          "assets/images/Talent Flow logo 1 1.png",
          // <-- IMPORTANT: Replace this with the path to your logo asset.
          height: 35, // You can adjust the height of your logo as needed.
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'الاعدادات',
                style: TextStyle(
                  color: Colors.black,
                  // Setting a color for the text.
                  fontSize: 16,
                  // Slightly increased font size for better visibility.
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24.0),
                  _buildSettingsOptionsCard(),
                ],
              ),
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
        // Aligns children to the end (right side in RTL).
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                // TODO: Replace with your user's profile image.
                backgroundImage: AssetImage(Images.appLogo),
              ),
              SizedBox(width: 16.0),
              Column(
                // Aligns text to the start (right side in RTL).
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "محمد عبد الرحمن",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "muhmmedahmed3@",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8.0),
          // These are the "Edit Profile" and "Upload Work" action buttons.
          _buildProfileOption(
            icon: Icons.edit_outlined, text: "تعديل الملف الشخصي",onTap: (){
              CustomNavigator.push(Routes.editProfile);
          }),
          _buildProfileOption(
              icon: Icons.file_upload_outlined, text: "رفع اعمال",onTap: (){
                CustomNavigator.push(Routes.addYourProject);
          }),
        ],
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String text,required VoidCallback onTap}) {
    return InkWell(
      onTap:onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 22),
            SizedBox(
              width: 8.w,
            ),
            Text(text, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptionsCard() {
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
              text: "ايه هو تلنت فلو؟",
              onTap: () {
                CustomNavigator.push(Routes.about);
              }),
          _buildSettingsMenuItem(
              icon: Icons.notifications_outlined,
              text: "الإشعارات",
              onTap: () {
                CustomNavigator.push(Routes.notifications);
              }),
          _buildSettingsMenuItem(
              icon: Icons.favorite_border,
              text: "المفضلة",
              onTap: () {
                CustomNavigator.push(Routes.favorites);
              }),
          _buildSettingsMenuItem(icon: Icons.support_agent, text: "الدعم"),
          _buildSettingsMenuItem(
              icon: Icons.list_alt_outlined, text: "الشروط والاحكام"    ,onTap:(){
                CustomNavigator.push(Routes.terms);
          } ),
          _buildSettingsMenuItem(
              icon: Icons.language_outlined,
              text: "اللغة",
              secondaryText: "English"),
          const SizedBox(height: 8.0),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8.0),
          _buildSettingsMenuItem(
            icon: Icons.logout,
            text: "تسجيل الخروج",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              CustomNavigator.push(Routes.login, clean: true);
            }
          ),
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
