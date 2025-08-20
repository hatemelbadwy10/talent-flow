import 'package:flutter/material.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/features/new_projects/widgets/project_card.dart';
class Favourite extends StatelessWidget {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          "assets/images/Talent Flow logo 1 1.png",
          height: 35,
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'المفضلة',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        // If you need a back button, Flutter automatically adds one.
        // To customize it, you can use the 'leading' property.
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ListAnimator(
          data: [
            ProjectCard(),
            SizedBox(height: 16),
            ProjectCard(),
            SizedBox(height: 16),
            ProjectCard(),
          ],
        ),
      ),
    );
  }
}
