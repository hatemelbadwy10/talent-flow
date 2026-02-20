import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/svg_images.dart';

class HomeHeaderSection extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;
  final String? userName;
  final String? userImage;
  final String? jobTitle;
  final int notificationCount;
  final int messageCount;
  final TextEditingController? searchController;
  final VoidCallback? onSearch;

  const HomeHeaderSection({
    super.key,
    this.onNotificationTap,
    this.onMessageTap,
    this.userName,
    this.userImage,
    this.jobTitle,
    this.notificationCount = 0,
    this.messageCount = 0,
    this.searchController,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background with teal gradient ──────────────────────────────
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0E8A8F),
                  Color(0xFF0C7D81),
                  Color(0xFF0A6E72),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            // Subtle wave/circle decoration
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  // Decorative circles for depth
                  Positioned(
                    top: -40,
                    left: -40,
                    child: Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: 60.w,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT.w,
                vertical: 16.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Right side: avatar + name (leading in RTL)
                  _UserInfo(
                    userName: userName,
                    jobTitle: jobTitle,
                    userImage: userImage,
                  ),

                  // Left side: action buttons (trailing in RTL)
                  Row(
                    children: [
                      _ActionButton(
                        icon: SvgImages.notification, // swap with your actual SVG key
                        isIcon: true,
                        badge: notificationCount,
                        onTap: onNotificationTap,
                      ),
                      SizedBox(width: 10.w),
                      _ActionButton(
                        icon: SvgImages.message,
                        badge: messageCount,
                        onTap: onMessageTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Floating search bar ────────────────────────────────────────
          Positioned(
            bottom: 16.h,
            left: Dimensions.PADDING_SIZE_DEFAULT.w,
            right: Dimensions.PADDING_SIZE_DEFAULT.w,
            child: HomeSearchBar(
              controller: searchController,
              onSearch: onSearch,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onSearch;
  final TextEditingController? controller;

  const HomeSearchBar({
    super.key,
    this.onSearch,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onSearch?.call(),
        decoration: InputDecoration(
          hintText: "home.search_service".tr(),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          // Search icon on the RIGHT side (leading in RTL)
          suffixIcon: Padding(
            padding: EdgeInsets.all(14.w),
            child: SvgPicture.asset(
              SvgImages.search,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                Colors.grey[400]!,
                BlendMode.srcIn,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UserInfo extends StatelessWidget {
  final String? userName;
  final String? jobTitle;
  final String? userImage;

  const _UserInfo({
    this.userName,
    this.jobTitle,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        _Avatar(image: userImage),

        SizedBox(width: 12.w),

        // Name + job title
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName ?? "Guest",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            if (jobTitle?.isNotEmpty ?? false) ...[
              SizedBox(height: 4.h),
              Text(
                jobTitle!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? image;

  const _Avatar({this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: image?.isNotEmpty ?? false
            ? Image.network(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final dynamic icon;
  final bool isIcon;
  final int badge;
  final VoidCallback? onTap;

  const _ActionButton({
    this.icon,
    this.isIcon = false,
    this.badge = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            child: Center(
              child: isIcon
                  ? const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.white,
                      size: 22,
                    )
                  : SvgPicture.asset(
                      icon as String,
                      height: 22,
                      width: 22,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),

          // Badge
          if (badge > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                constraints: BoxConstraints(minWidth: 20.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badge > 99 ? '99+' : badge.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}