import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/features/setting/bloc/notification_bloc.dart';
import 'package:talent_flow/features/setting/model/notification_model.dart';
import 'package:talent_flow/features/setting/repo/notification_repo.dart';
import 'package:talent_flow/features/setting/widgets/notification_card.dart';

import '../../../app/core/styles.dart';
import '../../../components/animated_widget.dart';
import '../../../data/config/di.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final Map<String, String> _types = {
    "all": "",          // All → request with ""
    "projects": "projects",
    "payments": "payments",
    "freelancers": "freelancers",
  };

  late final List<String> _tabTitles;   // keys (for UI)
  late final List<String> _tabValues;   // values (for request)

  @override
  void initState() {
    super.initState();

    _tabTitles = _types.keys.toList();
    _tabValues = _types.values.toList();

    _tabController = TabController(length: _tabTitles.length, vsync: this);

    // send first request when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(Add(arguments: _tabValues[0]));
    });

    // listen for tab changes and send request
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final selectedValue = _tabValues[_tabController.index];
      context.read<NotificationBloc>().add(Add(arguments: selectedValue));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc(sl()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('notifications'.tr()),
          bottom: TabBar(
            labelColor: Styles.PRIMARY_COLOR,
            controller: _tabController,
            indicatorColor: Styles.PRIMARY_COLOR,
            isScrollable: true,
            tabs: List.generate(
              _tabTitles.length,
                  (index) => Tab(text: _tabTitles[index]), // UI (translated key)
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
            _tabValues.length,
                (index) => _buildNotificationList(type: _tabValues[index]), // request value
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList({required String type}) {
    return BlocBuilder<NotificationBloc, AppState>(
      builder: (context, state) {
        if (state is Loading) {
          return _buildShimmerList();
        }

        if (state is Error) {
          return Center(child: Text("فشل تحميل الإشعارات".tr()));
        }

        if (state is Done) {
          final notifications = state.list?.cast<NotificationModel>();
          if (notifications == null || notifications.isEmpty) {
            return Center(child: Text("لا توجد إشعارات".tr()));
          }

          return ListAnimator(
            key: PageStorageKey(type),
            data: notifications
                .map((n) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: NotificationCard(notificationModel: n),
            ))
                .toList(),
          );
        }

        return _buildShimmerList();
      },
    );
  }

  /// Shimmer loading placeholder
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
