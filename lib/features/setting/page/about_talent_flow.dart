import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart'; // لعرض الـ HTML
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../home/widgets/jop_offer_listview_item.dart';
import '../bloc/about_bloc.dart';

class AboutTalentFlowView extends StatelessWidget {
  const AboutTalentFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AboutBloc(sl())..add(Add()), // يجيب البيانات
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar:  CustomAppBar(title: "about".tr()),
        body: SafeArea(
          child: BlocBuilder<AboutBloc, AppState>(
            builder: (context, state) {
              if (state is Loading) {
                return const ProjectCardShimmer();
              } else if (state is Error) {
                return const Center(
                  child: Text("حصل خطأ أثناء تحميل البيانات"),
                );
              } else if (state is Done) {
                final aboutHtml = state.data as String;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Html(data: aboutHtml), // عرض الـ HTML من API
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
