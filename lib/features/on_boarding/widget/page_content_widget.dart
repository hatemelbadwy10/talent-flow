import 'package:flutter/material.dart';

class PageContentWidget extends StatelessWidget {
  const PageContentWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  final String imagePath;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0C7D81),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF455A64),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
