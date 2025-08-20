import 'package:flutter/material.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/features/new_projects/widgets/add_offer_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_description.dart';

import '../widgets/project_details_card.dart';
class AddOfferScreen extends StatelessWidget {
  const AddOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(title: const Text('تقدم للمشروع'),
      centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const ProjectDetailsCard(),
              const ProjectDescription(),
              const AddOfferWidget(),
              CustomButton(text: "ارسال",isActive: true,
                onTap: (){},
              ),
              const SizedBox(height: 16,),
            ],
          ),
        ),
      ));
  }
}
