import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_event.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import '../bloc/setting_bloc.dart';
import '../model/help_model.dart';
import '../widgets/helo_dialoug.dart';
import '../widgets/profile_card.dart';
import '../widgets/setting_app_bar.dart';
import '../widgets/setting_item.dart';

Future<void> _confirmLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('settings_screen.logout_confirm_title'.tr()),
            content: Text('settings_screen.logout_confirm_body'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('cancel'.tr(),
                    style: const TextStyle(color: Styles.SUBTITLE)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  'settings_screen.logout'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ) ??
      false;

  if (!shouldLogout || !context.mounted) {
    return;
  }

  context.read<SettingsBloc>().add(Add());
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(sl()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'settings_screen.title'.tr(),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  const ProfileCard(),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
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
                    child: Builder(builder: (blocContext) {
                      return Column(
                        children: [
                          SettingsMenuItem(
                              icon: Icons.info_outline,
                              text: 'settings_screen.about_talent_flow'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.about);
                              }),
                          SettingsMenuItem(
                              icon: Icons.notifications_outlined,
                              text: 'settings_screen.notifications'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.notifications);
                              }),
                          SettingsMenuItem(
                              icon: Icons.favorite_border,
                              text: 'settings_screen.favorites'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.favorites);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.messages,
                              text: 'settings_screen.messages'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.chats);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.accountStatement,
                              text: 'settings_screen.account_statement'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.accountStatement);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.contracts,
                              text: 'settings_screen.contracts'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.contracts);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.bank,
                              text: 'settings_screen.bank_accounts'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.bankAccounts);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.identityVerification,
                              text:
                                  'settings_screen.identity_verification'.tr(),
                              onTap: () {
                                CustomNavigator.push(
                                  Routes.identityVerification,
                                );
                              }),
                          SettingsMenuItem(
                            onTap: () {
                              final settingsBloc = context.read<SettingsBloc>();

                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return BlocProvider.value(
                                    value: settingsBloc,
                                    child: HelpDialog(
                                      onSend: (HelpModel model) {
                                        settingsBloc
                                            .add(Click(arguments: model));
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icons.support_agent,
                            text: 'settings_screen.support'.tr(),
                          ),
                          SettingsMenuItem(
                              icon: Icons.list_alt_outlined,
                              text: 'settings_screen.terms_and_conditions'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.terms);
                              }),
                          SettingsMenuItem(
                              icon: Icons.language_outlined,
                              text: 'settings_screen.language'.tr(),
                              secondaryText:
                                  'settings_screen.current_language'.tr(),
                              onTap: () {
                                // This logic switches between English and Arabic
                                Locale currentLocale = blocContext.locale;
                                if (currentLocale == const Locale('en')) {
                                  blocContext.setLocale(const Locale('ar'));
                                } else {
                                  blocContext.setLocale(const Locale('en'));
                                }
                              }),
                          const SizedBox(height: 8.0),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 8.0),
                          SettingsMenuItem(
                            icon: Icons.logout,
                            text: 'settings_screen.logout'.tr(),
                            textColor: Colors.red,
                            iconColor: Colors.red,
                            onTap: () {
                              _confirmLogout(blocContext);
                            },
                          ),
                          SizedBox(
                            height: 100.h,
                          )
                        ],
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative Solution: If you prefer BlocProvider.value approach
class SettingAlternative extends StatelessWidget {
  const SettingAlternative({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(sl()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'settings_screen.title'.tr(),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  const ProfileCard(),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
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
                    child: Builder(builder: (blocContext) {
                      return Column(
                        children: [
                          SettingsMenuItem(
                              icon: Icons.info_outline,
                              text: 'settings_screen.about_talent_flow'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.about);
                              }),
                          SettingsMenuItem(
                              icon: Icons.notifications_outlined,
                              text: 'settings_screen.notifications'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.notifications);
                              }),
                          SettingsMenuItem(
                              icon: Icons.favorite_border,
                              text: 'settings_screen.favorites'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.favorites);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.messages,
                              text: 'settings_screen.messages'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.chats);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.accountStatement,
                              text: 'settings_screen.account_statement'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.accountStatement);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.contracts,
                              text: 'settings_screen.contracts'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.contracts);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.bank,
                              text: 'settings_screen.bank_accounts'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.bankAccounts);
                              }),
                          SettingsMenuItem(
                              svgIconPath: SvgImages.identityVerification,
                              text:
                                  'settings_screen.identity_verification'.tr(),
                              onTap: () {
                                CustomNavigator.push(
                                  Routes.identityVerification,
                                );
                              }),
                          SettingsMenuItem(
                            onTap: () {
                              final settingsBloc =
                                  blocContext.read<SettingsBloc>();

                              showDialog(
                                context: blocContext,
                                builder: (dialogContext) {
                                  // Provide the bloc to the dialog tree
                                  return BlocProvider<SettingsBloc>.value(
                                    value: settingsBloc,
                                    child: HelpDialog(
                                      onSend: (HelpModel model) {
                                        // Now you can use dialogContext safely
                                        dialogContext.read<SettingsBloc>().add(
                                              Click(arguments: model),
                                            );
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            icon: Icons.support_agent,
                            text: 'settings_screen.support'.tr(),
                          ),
                          SettingsMenuItem(
                              icon: Icons.list_alt_outlined,
                              text: 'settings_screen.terms_and_conditions'.tr(),
                              onTap: () {
                                CustomNavigator.push(Routes.terms);
                              }),
                          SettingsMenuItem(
                              icon: Icons.language_outlined,
                              text: 'settings_screen.language'.tr(),
                              secondaryText:
                                  'settings_screen.current_language'.tr(),
                              onTap: () {
                                Locale currentLocale = blocContext.locale;
                                if (currentLocale == const Locale('en')) {
                                  blocContext.setLocale(const Locale('ar'));
                                } else {
                                  blocContext.setLocale(const Locale('en'));
                                }
                              }),
                          const SizedBox(height: 8.0),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 8.0),
                          SettingsMenuItem(
                            icon: Icons.logout,
                            text: 'settings_screen.logout'.tr(),
                            textColor: Colors.red,
                            iconColor: Colors.red,
                            onTap: () {
                              _confirmLogout(blocContext);
                            },
                          ),
                          SizedBox(
                            height: 100.h,
                          )
                        ],
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
