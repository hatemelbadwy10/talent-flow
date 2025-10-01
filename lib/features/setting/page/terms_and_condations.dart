import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:talent_flow/features/home/widgets/jop_offer_listview_item.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../bloc/terms_bloc.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      TermsBloc(sl())..add(Add()), // Fire event
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: CustomAppBar(title: "terms_and_conditions".tr()),
        body: SafeArea(
          child: BlocBuilder<TermsBloc, AppState>(
            builder: (context, state) {
              if (state is Loading) {
                return const ProjectCardShimmer();
              } else if (state is Error) {
                return const Center(child: Text("حصل خطأ أثناء تحميل البيانات"));
              } else if (state is Done) {
                final termsHtml = state.data as String;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Html(data: termsHtml), // Render API HTML
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
