import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: .25),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage:
              AssetImage('assets/images/profile_placeholder.png'),
            ),
            const SizedBox(width: 12.0),

            Expanded(
              child: Column(
                // Aligns all text to the start (right side in RTL).
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This row holds the main title and the timestamp.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Using Flexible to prevent the title from overflowing if it's too long.
                      const Flexible(
                        child: Text(
                          "محمد عبد الرحمن، مصمم منتجات",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          // Hides overflow with an ellipsis (...).
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8), // Space between title and time
                      Text(
                        "2 يوم", // The timestamp.
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0), // Vertical spacing.

                  // The main description of the notification.
                  Text(
                    "المشروع عبارة عن تطبيق كرة قدم",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  // The tags/keywords related to the notification.
                  Text(
                    "NATIVE  ANDROID & IOS  LARAVEL  BACKEND  SENIOR LEVEL",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      // Adds a bit of space between letters for readability.
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}