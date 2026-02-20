import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. Import the package
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/new_projects/widgets/add_offer_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_description.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../projects/bloc/my_projects_bloc.dart';
import '../../projects/model/single_project_model.dart';
import '../widgets/project_details_card.dart';

class AddOfferScreen extends StatelessWidget {
  final Map<String, dynamic>?argument;

  const AddOfferScreen({super.key, this.argument});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      MyProjectsBloc(sl())
        ..add(Click(arguments: argument?['id'])),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? true? 'submit_offer_title'.tr(): 'projectData'.tr()),
          centerTitle: true,
          surfaceTintColor: Colors.white,
        ),
        body:BlocBuilder<MyProjectsBloc, AppState>(
          builder: (context, state) {
            if(state is Done){

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                       ProjectDetailsCard(singleProjectModel: state.model as SingleProjectModel,),
                       ProjectDescription(singleProjectModel: state.model as SingleProjectModel,),
                       sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? true?
                       AddOfferWidget(id:argument?['id'],):SizedBox(),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            }
            else if  (state is Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (state is Error) {
              return  Center(child: Text("error.loading".tr()));
            }
            return Container();
          },
        ),
      ),
    );
  }
}