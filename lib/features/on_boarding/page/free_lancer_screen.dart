import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import '../../../app/core/images.dart';
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
          Image.asset(
            Images.onBoardingPhoto,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),


          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0C7D81),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3116,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                    sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, true);
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

                    sl<SharedPreferences>().setBool(AppStorageKey.isFreelancer, false);
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
    );
  }
}