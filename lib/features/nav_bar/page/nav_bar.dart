import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/new_projects/page/new_project.dart';
import 'package:talent_flow/features/payment/page/payment_page.dart';
import 'package:talent_flow/features/projects/page/my_projects.dart';
import 'package:talent_flow/features/setting/page/setting.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../home/page/home_view.dart';
import '../bloc/nav_bar_bloc.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Determine the user's status inside the build method.
    // This assumes `isFreelancer` is a boolean key. Note the corrected syntax for `sl`.
    final bool isFreelancer = sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;

    // 2. Define all your navigation items dynamically.
    // These are now regular local variables, not static.
    final List<Widget> widgetOptions = [
      const Setting(),
      const OwnerProjects(),
      const HomeView(),
      const NewProject(),
      // Use a collection 'if' to conditionally add the PaymentPage.
      if (isFreelancer) const PaymentPage(),
    ];

    final List<IconData> unselectedIcons = [
      IconsaxPlusLinear.setting_2,
      IconsaxPlusLinear.briefcase,
      IconsaxPlusLinear.home_2,
      IconsaxPlusLinear.add_square,
      if (isFreelancer) IconsaxPlusLinear.wallet_3,
    ];

    final List<IconData> selectedIcons = [
      IconsaxPlusBold.setting_2,
      IconsaxPlusBold.briefcase,
      IconsaxPlusBold.home_2,
      IconsaxPlusBold.add_square,
      if (isFreelancer) IconsaxPlusBold.wallet_3,
    ];

    final List<String> labels = [
      "الأعدادات",
      "إعمالي",
      "الرئيسية",
      "مشاريع جديدة",
      if (isFreelancer) "الدفع",
    ];

    return BlocProvider(
      create: (context) => NavBarBloc(),
      child: BlocBuilder<NavBarBloc, AppState>(
        builder: (context, state) {
          int selectedIndex = 2; // Default index
          if (state is Done) {
            selectedIndex = state.data;
          }

          // Safety check: Prevent a RangeError if the number of tabs changes
          // and the previously selected index is now out of bounds.
          if (selectedIndex >= widgetOptions.length) {
            selectedIndex = 2; // Reset to a safe default (e.g., home)
          }

          return Material(
            child: Stack(
              children: [
                widgetOptions[selectedIndex],
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CurvedNavigationBar(
                    index: selectedIndex,
                    backgroundColor: Colors.transparent,
                    color: Styles.PRIMARY_COLOR,
                    buttonBackgroundColor: Colors.transparent,
                    // 3. Use the dynamic length of your lists instead of a fixed number.
                    items: List.generate(labels.length, (index) {
                      final isSelected = index == selectedIndex;
                      Widget iconWidget;
                      if (isSelected) {
                        iconWidget = Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Styles.PRIMARY_COLOR, Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.3, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Icon(
                            selectedIcons[index],
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      } else {
                        iconWidget = Icon(
                          unselectedIcons[index],
                          color: Colors.white,
                          size: 24,
                        );
                      }
                      return CurvedNavigationBarItem(
                        child: iconWidget,
                        label: labels[index],
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      );
                    }),
                    onTap: (index) {
                      context.read<NavBarBloc>().add(Click(arguments: index));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}