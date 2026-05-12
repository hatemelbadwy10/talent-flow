import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/core/app_storage_keys.dart';
import '../app/core/images.dart';
import '../navigation/custom_navigation.dart';
import '../navigation/routes.dart';

/// Global User Header Widget
/// This widget displays user information and updates automatically when UserBloc state changes
class GlobalUserHeader extends StatefulWidget {
  final bool showUserImage;
  final bool showUserName;
  final double? userImageRadius;
  final TextStyle? userNameStyle;
  final VoidCallback? onUserTap;

  const GlobalUserHeader({
    super.key,
    this.showUserImage = true,
    this.showUserName = true,
    this.userImageRadius = 20,
    this.userNameStyle,
    this.onUserTap,
  });

  @override
  State<GlobalUserHeader> createState() => _GlobalUserHeaderState();
}

class _GlobalUserHeaderState extends State<GlobalUserHeader> {
  @override
  void initState() {
    super.initState();
    // Fetch latest user data when header initializes
    context.read<UserBloc>().add(Click());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, AppState>(
      builder: (context, state) {
        final userBloc = context.read<UserBloc>();
        final user = userBloc.user;
        final prefs = sl<SharedPreferences>();

        // Get data from UserBloc or fallback to SharedPreferences
        final userName = user?.name ?? prefs.getString(AppStorageKey.userName) ?? "User";
        final userImage = user?.profileImage ?? prefs.getString(AppStorageKey.userImage) ?? Images.appLogo;

        return GestureDetector(
          onTap: widget.onUserTap ??
              () {
                CustomNavigator.push(Routes.profile);
              },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showUserImage)
                CircleAvatar(
                  radius: widget.userImageRadius,
                  backgroundImage: NetworkImage(userImage),
                ),
              if (widget.showUserImage && widget.showUserName)
                const SizedBox(width: 12),
              if (widget.showUserName)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Hello".tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      userName.split(' ').first,
                      style: widget.userNameStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple User Avatar Widget
/// Displays only the user's avatar with status update
class GlobalUserAvatar extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showNotificationBadge;
  final int? notificationCount;

  const GlobalUserAvatar({
    super.key,
    this.radius = 24,
    this.onTap,
    this.showNotificationBadge = false,
    this.notificationCount,
  });

  @override
  State<GlobalUserAvatar> createState() => _GlobalUserAvatarState();
}

class _GlobalUserAvatarState extends State<GlobalUserAvatar> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(Click());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, AppState>(
      builder: (context, state) {
        final userBloc = context.read<UserBloc>();
        final user = userBloc.user;
        final prefs = sl<SharedPreferences>();

        final userImage = user?.profileImage ?? prefs.getString(AppStorageKey.userImage) ?? Images.appLogo;
        final notificationCount = widget.notificationCount ?? user?.unreadNotificationsCount ?? 0;

        return GestureDetector(
          onTap: widget.onTap ?? () => CustomNavigator.push(Routes.profile),
          child: Stack(
            children: [
              CircleAvatar(
                radius: widget.radius,
                backgroundImage: NetworkImage(userImage),
              ),
              if (widget.showNotificationBadge && notificationCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount > 99 ? '99+' : notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// User Name Display Widget
/// Shows only the user's name with real-time updates
class GlobalUserName extends StatefulWidget {
  final TextStyle? textStyle;
  final bool showGreeting;
  final VoidCallback? onTap;

  const GlobalUserName({
    super.key,
    this.textStyle,
    this.showGreeting = true,
    this.onTap,
  });

  @override
  State<GlobalUserName> createState() => _GlobalUserNameState();
}

class _GlobalUserNameState extends State<GlobalUserName> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(Click());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, AppState>(
      builder: (context, state) {
        final userBloc = context.read<UserBloc>();
        final user = userBloc.user;
        final prefs = sl<SharedPreferences>();

        final userName = user?.name ?? prefs.getString(AppStorageKey.userName) ?? "User";

        return GestureDetector(
          onTap: widget.onTap,
          child: widget.showGreeting
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Hello".tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      userName.split(' ').first,
                      style: widget.textStyle ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Text(
                  userName,
                  style: widget.textStyle ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        );
      },
    );
  }
}
