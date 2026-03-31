import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/user_completion_guard.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

import '../../../data/config/di.dart';
import '../../../app/core/app_state.dart';
import '../bloc/portofilo_form_bloc.dart';
import '../widgets/protofilo_form.dart';

class AddYourProjects extends StatelessWidget {
  const AddYourProjects({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  bool get _fromOnboarding => arguments?['fromOnboarding'] == true;

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? true;
    final canSkipToIdentity = !UserCompletionGuard.status.identityAuthenticated;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          "assets/images/Talent Flow logo 1 1.png",
          height: 35,
        ),
        actions: [
          if (isFreelancer && canSkipToIdentity)
            TextButton(
              onPressed: () {
                CustomNavigator.push(
                  Routes.identityVerification,
                  replace: true,
                  arguments: {'fromOnboarding': _fromOnboarding},
                );
              },
              child: Text(
                "user_completion.skip".tr(),
                style: const TextStyle(
                  color: Styles.PRIMARY_COLOR,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                "add_project.add_project".tr(),
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
        child: Padding(
          padding:
              EdgeInsetsGeometry.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PortfolioInfoCard(),
                BlocProvider(
                  create: (context) => PortfolioFormBloc(sl()),
                  child: BlocListener<PortfolioFormBloc, AppState>(
                    listener: (context, state) async {
                      if (state is! Done || state.reload != true) {
                        return;
                      }

                      await UserCompletionGuard.updateStoredFlags(
                        addedWorks: true,
                      );

                      AppCore.showSnackBar(
                        notification: AppNotification(
                          message: 'user_completion.work_completed'.tr(),
                          backgroundColor: Styles.ACTIVE,
                          isFloating: true,
                        ),
                      );

                      if (UserCompletionGuard.status.identityAuthenticated) {
                        if (_fromOnboarding) {
                          CustomNavigator.push(Routes.navBar, clean: true);
                        } else {
                          CustomNavigator.pop(result: true);
                        }
                        return;
                      }

                      CustomNavigator.push(
                        Routes.identityVerification,
                        replace: true,
                        arguments: {'fromOnboarding': _fromOnboarding},
                      );
                    },
                    child: const PortfolioUploadForm(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioInfoCard extends StatelessWidget {
  const PortfolioInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "add_projects.title".tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8.0),
          const Divider(
            color: Color(0xFFEEEEEE),
            thickness: 1.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            "add_projects.description".tr(),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListItem("add_projects.rule1".tr()),
              _buildListItem("add_projects.rule2".tr()),
              _buildListItem("add_projects.rule3".tr()),
              _buildListItem("add_projects.rule4".tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
