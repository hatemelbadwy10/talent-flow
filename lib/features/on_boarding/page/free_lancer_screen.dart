import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import '../../../app/core/images.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key,this.arguments});
  final Map<String,dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Styles.PRIMARY_COLOR.withValues(alpha: 0.3),
                  Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(Images.onBoardingPhoto, height: 300, width: 300),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3116,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Styles.PRIMARY_COLOR,
                    Styles.WHITE_COLOR,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 24,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChoiceCard(
                  iconPath: Images.jopSearcher,
                  text: 'user_selection.find_service_card'.tr(),
                  onTap: () {
                    sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, false);
                    log('arguments?["from_login"]${arguments?["from_login"]}');
                    if(arguments?["from_login"] == true){
                      CustomNavigator.push(Routes.register);
                    }
                    else{
                      CustomNavigator.push(Routes.login,clean: true);
                    }

                  },
                ),
                const SizedBox(width: 16),
                _buildChoiceCard(
                  iconPath: Images.penIcon,
                  text: 'user_selection.freelancer_card'.tr(),
                  onTap: () {

                    sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, true);
                    log('arguments?["from_login"]${arguments?["from_login"]}');
                    if(arguments?["from_login"] == true){
                    CustomNavigator.push(Routes.register);
                  }
                    else{
                      CustomNavigator.push(Routes.login,clean: true);
                    }
    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: Styles.WHITE_COLOR,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(iconPath, height: 44, width: 44),
                const SizedBox(height: 16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}