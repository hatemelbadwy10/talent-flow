import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/features/setting/widgets/notification_card.dart';

import '../../../app/core/styles.dart';
import '../../../components/animated_widget.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'notifications'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        // The TabBar is placed at the bottom of the AppBar.
        bottom: TabBar(
          controller: _tabController,
          // Makes the tabs scrollable if they don't fit on the screen.
          isScrollable: true,
          // Style for the selected tab label.
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: Styles.PRIMARY_COLOR,
          // Color for unselected tabs' text.
          unselectedLabelColor: Colors.grey.shade600,
          // Color and style of the indicator line under the selected tab.
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3.0,
          // Define the tabs themselves.
          tabs: [
            Tab(text: "all".tr()),      // "All"
            Tab(text: "projects".tr()),  // "Projects"
            Tab(text: "payments".tr()),       // "Payment"
            Tab(text: "freeLancer".tr()), // "Freelancers"
          ],
        ),
      ),
      // The TabBarView displays the content for the currently selected tab.
      body: TabBarView(
        controller: _tabController,
        // The children must correspond in order to the tabs in the TabBar.
        children: [
          // Content for "All" tab
          _buildNotificationList(key: 'all_notifications', count: 10),

          // Content for "Projects" tab
          // TODO: Replace with actual filtered data for projects
          _buildNotificationList(key: 'project_notifications', count: 4),

          // Content for "Payment" tab
          // TODO: Replace with actual filtered data for payments
          _buildNotificationList(key: 'payment_notifications', count: 2),

          // Content for "Freelancers" tab
          // TODO: Replace with actual filtered data for freelancers
          _buildNotificationList(key: 'freelancer_notifications', count: 6),
        ],
      ),
    );
  }

  /// A reusable widget to build a list of notifications.
  /// This avoids code duplication in the TabBarView.
  Widget _buildNotificationList({required String key, required int count}) {
    // Using a PageStorageKey helps preserve the scroll position of each
    // list when switching between tabs.
    return ListAnimator(
      key: PageStorageKey(key),
      data: List.generate(
        count,
            (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: NotificationCard(),
        ),
      ),
    );
  }
}