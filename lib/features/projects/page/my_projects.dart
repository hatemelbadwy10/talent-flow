import 'package:flutter/material.dart';
import '../../../components/grid_list_animator.dart';
import '../widgets/my_projects_card.dart';

class OwnerProjects extends StatelessWidget {
  const OwnerProjects({super.key});

  @override
  Widget build(BuildContext context) {
    // حساب نسبة العرض إلى الارتفاع من تصميم Figma
    const double cardWidth = 190;
    const double cardHeight = 280;
    const double aspectRatio = cardWidth / cardHeight; // ≈ 0.662

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('مشاريعي'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: GridView.builder(
            itemCount: 2, // عدد الكروت
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عمودين
              crossAxisSpacing: 2, // المسافة بين الأعمدة
              mainAxisSpacing: 2, // المسافة بين الصفوف
              childAspectRatio: aspectRatio, // نسبة العرض إلى الارتفاع
            ),
            itemBuilder: (context, index) {
              return ProjectPortfolioCard(
                status:
                ProjectStatus.values[index % ProjectStatus.values.length],
                title: "مشروع رقم ${index + 1}",
                likes: 10 + index,
                views: 50 + index * 2,
              );
            },
          ),
        ),
      ),
    );
  }
}
