import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../../new_projects/widgets/project_description.dart';
import '../../new_projects/widgets/project_details_card.dart';
import '../bloc/my_projects_bloc.dart';
import '../model/single_project_model.dart';
import '../widgets/single_project_shimmer.dart';

class SingleProjectView extends StatelessWidget {
  final Map<String, dynamic> arguments;

  const SingleProjectView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    final bool isFreelancer =
        sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;

    return BlocProvider(
      create: (context) =>
      MyProjectsBloc(sl())..add(Click(arguments: arguments['id'])), // 👈 هنا
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('project_details'.tr()),
          centerTitle: true,
          surfaceTintColor: Colors.white,
        ),
        body: BlocBuilder<MyProjectsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const SingleProjectViewShimmer();
            } else if (state is Error) {
              return const Center(child: Text("فشل تحميل المشروع"));
            } else if (state is Done && state.model is SingleProjectModel) {
              final project = state.model as SingleProjectModel;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectDetailsCard(
                        singleProjectModel: project,
                       ),
                      ProjectDescription(singleProjectModel: project),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:isFreelancer? null: _buildPaymentButton(context),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            CustomNavigator.push(Routes.payment);
          },
          backgroundColor: Styles.PRIMARY_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: const Icon(
            Icons.credit_card,
            color: Colors.white,
          ),
          label: Text(
            "pay_for_project".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}