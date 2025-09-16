import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "الشروط والأحكام",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<TermsBloc, AppState>(
            builder: (context, state) {
              if (state is Loading) {
                return const Center(child: CircularProgressIndicator());
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
