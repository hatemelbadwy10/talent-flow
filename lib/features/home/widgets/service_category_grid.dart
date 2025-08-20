import 'package:flutter/material.dart';
import 'package:talent_flow/features/home/widgets/service_widget.dart';

import '../../../components/grid_list_animator.dart';

class ServiceCategoriesGrid extends StatelessWidget {
  const ServiceCategoriesGrid({super.key});

  // --- 1. DEFINE YOUR DATA ---
  // Make sure the SVG paths in 'icon' match your actual asset files.
  final List<Map<String, String>> serviceData = const [
    {'icon': 'assets/svgs/code.svg', 'label': 'التصميم الجرافيكي'},
    {'icon': 'assets/svgs/code.svg', 'label': 'التسويق الرقمي'},
    {'icon': 'assets/svgs/code.svg', 'label': 'الفيديو والرسوم المتحركة'},
    {'icon': 'assets/svgs/code.svg', 'label': 'البرنامج والتكنولوجيا'},
    {'icon': 'assets/svgs/code.svg', 'label': 'الوسيقى والصوت'},
    {'icon': 'assets/svgs/code.svg', 'label': 'تصوير للمنتجات'},
    {'icon': 'assets/svgs/code.svg', 'label': 'تصميم واجهة وتجربة المستخدم'},
    {'icon': 'assets/svgs/code.svg', 'label': 'بناء خدمات الذكاء الاصطناعي'},
  ];

  @override
  Widget build(BuildContext context) {
    // --- 2. BUILD THE UI ---
    return GridListAnimatorWidget(
      columnCount: 4, // As per your design
      aspectRatio: .50, // You can adjust this for perfect spacing
      padding: const EdgeInsets.all( 2),
      // --- 3. DYNAMICALLY CREATE WIDGETS FROM DATA ---
      items: serviceData.map((data) {
        // For each item in the data list...
        return ServiceWidget(
          // ...create a ServiceWidget with its specific data
          iconPath: data['icon']!,
          label: data['label']!,
        );
      }).toList(), // Convert the result into a List<Widget>
    );
  }
}