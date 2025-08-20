import 'package:flutter/material.dart';

// You can replace these with your actual dimension/style imports
// import 'package:talent_flow/app/core/dimensions.dart';
// import 'package:talent_flow/app/core/styles.dart';

class ServiceCategoryView extends StatelessWidget {
  const ServiceCategoryView({super.key});

  // Data for the list items, extracted from the image
  final List<Map<String, dynamic>> serviceCategories = const [
    {
      'icon': Icons.palette_outlined,
      'title': 'التصميم الجرافيكي',
      'subtitle': 'الشعار وهوية العلامة التجارية',
    },
    {
      'icon': Icons.add,
      'title': 'التسويق الرقمي',
      'subtitle': 'التسويق عبر وسائل التواصل الاجتماعي وتحسين محركات البحث',
    },
    {
      'icon': Icons.video_camera_back_outlined,
      'title': 'الفيديو والرسوم المتحركة',
      'subtitle': 'تحرير الفيديو وإعلانات الفيديو',
    },
    {
      'icon': Icons.music_note_outlined,
      'title': 'الموسيقى والصوت',
      'subtitle': 'المنتجون والملحنون',
    },
    {
      'icon': Icons.code_outlined,
      'title': 'البرنامج والتكنولوجيا',
      'subtitle': 'تطوير المواقع والتطبيقات',
    },
    {
      'icon': Icons.camera_alt_outlined,
      'title': 'تصوير المنتجات',
      'subtitle': 'مصوري المنتجات',
    },
    {
      'icon': Icons.settings_suggest_outlined,
      'title': 'بناء خدمة الذكاء الاصطناعي',
      'subtitle': 'قم ببناء تطبيق الذكاء الاصطناعي الخاص بك',
    },
    {
      'icon': Icons.data_usage_outlined,
      'title': 'بيانات',
      'subtitle': 'علم البيانات والذكاء الاصطناعي',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Using Directionality to ensure the layout is Right-to-Left (RTL)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,

          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "فئة الخدمة",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView.separated(
          itemCount: serviceCategories.length,
          itemBuilder: (context, index) {
            final category = serviceCategories[index];
            return ServiceCategoryTile(
              icon: category['icon'],
              title: category['title'],
              subtitle: category['subtitle'],
              onTap: () {
                // TODO: Add navigation logic for the selected category
                print('${category['title']} tapped');
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF2F2F2),
              endIndent: 20,
              indent: 20,
            );
          },
        ),
      ),
    );
  }
}

/// A reusable widget for displaying a single service category item.
class ServiceCategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceCategoryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // Icon with a decorated background
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF444444),
                size: 24,
              ),
            ),
            const SizedBox(width: 16.0),
            // Title and Subtitle column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // Trailing arrow icon
            const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}