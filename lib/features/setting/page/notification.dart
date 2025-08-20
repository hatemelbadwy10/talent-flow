import 'package:flutter/material.dart';
import 'package:talent_flow/features/setting/widgets/notification_card.dart';

import '../../../components/animated_widget.dart';

class Notification extends StatelessWidget {
  const Notification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'الاشعارات',
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
      body: ListAnimator(
        data: List.generate((10), (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: NotificationCard(),
        )),
      ),
    );
  }
}
