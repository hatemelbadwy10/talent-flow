import 'package:flutter/material.dart';
class PageContentWidget extends StatelessWidget {
  const PageContentWidget({super.key, required this.title, required this.description});
final String title, description;
  @override
  Widget build (BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 15),
          Text(description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}
