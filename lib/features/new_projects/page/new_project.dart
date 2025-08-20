import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/components/animated_widget.dart';
import '../../../app/core/app_storage_keys.dart';
import '../../../data/config/di.dart';
import '../widgets/project_card.dart';

class NewProject extends StatelessWidget {
  const NewProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          'مشاريع جديدة',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        leading:
            sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false
                ? IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {
                      // Define what happens when the button is pressed.
                      // For example, navigate to a "Create Project" screen.
                      print("Add button pressed for non-freelancer.");
                    },
                  )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 16.0),
        child: ListAnimator(
          data: List.generate(10, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: ProjectCard(),
          )),
        ),
      ),
    );
  }
}
