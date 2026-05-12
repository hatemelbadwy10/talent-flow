import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/app/core/svg_images.dart';

import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/images.dart';
import '../../../data/config/di.dart';
import '../../../main_blocs/user_bloc.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when widget initializes
    context.read<UserBloc>().add(Click());
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // Ensure widget rebuilds on locale change
    return BlocBuilder<UserBloc, AppState>(
      builder: (context, state) {
        final prefs = sl<SharedPreferences>();
        final userBloc = context.read<UserBloc>();
        final user = userBloc.user;
        
        // Get data from UserBloc or fallback to SharedPreferences
        final userName = user?.name ?? prefs.getString(AppStorageKey.userName) ?? "user_example.name".tr();
        final userEmail = user?.email ?? prefs.getString(AppStorageKey.userEmail) ?? "user_example.email".tr();
        final userImage = user?.profileImage ?? prefs.getString(AppStorageKey.userImage) ?? Images.appLogo;
        
        final isFreelancer = prefs.getBool(AppStorageKey.isFreelancer) ?? false;
        final accountTypeKey = isFreelancer
            ? 'settings_screen.account_type_freelancer'
            : 'settings_screen.account_type_entrepreneur';
        final userId = user?.id ?? int.tryParse(prefs.getString(AppStorageKey.userId) ?? '');
        
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(userImage),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          userEmail,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          accountTypeKey.tr(),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).onTap(
                userId != null
                    ? () {
                        CustomNavigator.push(Routes.profile);
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 16.0),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8.0),
              _buildProfileOption(
                icon: Icons.edit_outlined,
                text: 'settings_screen.edit_profile'.tr(),
                onTap: () {
                  CustomNavigator.push(Routes.editProfile);
                },
              ),
              _buildProfileOption(
                icon: Icons.file_upload_outlined,
                text: isFreelancer
                    ? 'settings_screen.upload_work'.tr()
                    : 'settings_screen.add_projects'.tr(),
                onTap: () {
                  CustomNavigator.push(
                    isFreelancer ? Routes.addYourProject : Routes.addProject,
                  );
                },
              ),
              _buildProfileOption(
                svgIconPath: SvgImages.dashboard,
                text: 'settings_screen.dashboard'.tr(),
                onTap: () {
                  CustomNavigator.push(Routes.dashboard);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    IconData? icon,
    String? svgIconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    assert(icon != null || svgIconPath != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          if (svgIconPath != null)
            SvgPicture.asset(
              svgIconPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(icon, color: Colors.grey.shade600, size: 22),
          SizedBox(width: 8.w),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    )
        .onTap(onTap, borderRadius: BorderRadius.circular(12))
        .setContainerToView();
  }
}
