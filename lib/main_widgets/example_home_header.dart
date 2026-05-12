import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/main_widgets/global_user_header.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

/// Example Home Header Widget using Global User State
class ExampleHomeHeader extends StatelessWidget {
  const ExampleHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Left side: User greeting and avatar
            const Expanded(
              child: GlobalUserHeader(
                showUserImage: true,
                showUserName: true,
                userImageRadius: 24,
                userNameStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),

            /// Right side: Notifications and settings
            Row(
              children: [
                /// Notification Bell with badge
                GestureDetector(
                  onTap: () => CustomNavigator.push(Routes.notifications),
                  child: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 24),
                      // You can add notification count here
                      BlocBuilder<UserBloc, AppState>(
                        builder: (context, state) {
                          final notificationCount =
                              context.read<UserBloc>().user?.unreadNotificationsCount ?? 0;
                          if (notificationCount > 0) {
                            return Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  notificationCount > 9 ? '9+' : '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                /// Messages icon with badge
                GestureDetector(
                  onTap: () => CustomNavigator.push(Routes.chats),
                  child: Stack(
                    children: [
                      const Icon(Icons.mail_outline, size: 24),
                      // Message count badge
                      BlocBuilder<UserBloc, AppState>(
                        builder: (context, state) {
                          final messageCount =
                              context.read<UserBloc>().user?.unreadMessagesCount ?? 0;
                          if (messageCount > 0) {
                            return Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  messageCount > 9 ? '9+' : '$messageCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternative: Simpler Home Header
class SimpleHomeHeader extends StatelessWidget {
  const SimpleHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          /// User avatar only
          const GlobalUserAvatar(
            radius: 28,
            showNotificationBadge: true,
          ),
          const SizedBox(width: 12),

          /// User name and greeting
          const Expanded(
            child: GlobalUserName(
              showGreeting: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Advanced: Home Header with Search and Filters
class AdvancedHomeHeader extends StatefulWidget {
  final VoidCallback? onSearchChanged;

  const AdvancedHomeHeader({super.key, this.onSearchChanged});

  @override
  State<AdvancedHomeHeader> createState() => _AdvancedHomeHeaderState();
}

class _AdvancedHomeHeaderState extends State<AdvancedHomeHeader> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch user data when header initializes
    context.read<UserBloc>().add(Click());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Top row: User info and icons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Expanded(
                child: GlobalUserHeader(
                  showUserImage: true,
                  showUserName: true,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => CustomNavigator.push(Routes.notifications),
              ),
            ],
          ),
        ),

        /// Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => widget.onSearchChanged?.call(),
            decoration: InputDecoration(
              hintText: 'search'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
