import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import '../../../data/config/di.dart';
import '../../projects/widgets/projects_shimmer.dart';
import '../bloc/terms_bloc.dart';
import '../bloc/static_content_state.dart';
import '../repo/terms_condation_repo.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TermsBloc(repository: sl<TermsAndConditionRepo>())
        ..add(const TermsRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: CustomAppBar(title: "terms_and_conditions".tr()),
        body: SafeArea(
          child: BlocBuilder<TermsBloc, StaticContentState>(
            builder: (context, state) {
              if (state is StaticContentLoading) {
                return const ProjectCardShimmer();
              } else if (state is StaticContentFailed) {
                return Center(child: Text("failed_to_load_data".tr()));
              } else if (state is StaticContentLoaded) {
                final termsHtml = state.html;
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
