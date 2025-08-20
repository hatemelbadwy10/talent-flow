import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: User Info Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=56'), // Placeholder image
                    ),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "محمد عبد الرحمن",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "مصمم ويب",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () {
                    // TODO: Handle favorite button tap
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 2: Metadata (Time, Views, Offers)
            Row(
              children: [
                _buildMetaInfo(icon: Icons.access_time, text: "منذ 42 دقيقة"),
                const SizedBox(width: 16),
                _buildMetaInfo(icon: Icons.visibility_outlined, text: "54"),
                const SizedBox(width: 16),
                _buildMetaInfo(icon: Icons.cases_outlined, text: "عرض واحد"),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 3: Project Description
            const Text(
              "المشروع عبارة عن تطبيق كرة قدم NATIVE ANDROID & IOS مربوط بـ LARAVEL BACKEND المطلوب لعمل SENIOR LEVEL التالي تعديل على طريقة الاشعارات حيث تم تغيير طريقة ارسال الاشعارات من جوجل فايز بيز........",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF444444),
                height: 1.5, // Line height for better readability
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16.0),
            Divider(
              height: 1,
              thickness: 2,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16.0),

            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  CustomNavigator.push(sl<SharedPreferences>()
                              .getBool(AppStorageKey.isFreelancer) ??
                          false
                      ? Routes.addProject
                      : Routes.addOffer);
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                          false
                      ? "مشروع مماثل"
                      : "اضف عرضك",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.PRIMARY_COLOR, // Teal color
                  minimumSize: const Size(double.infinity, 50), // Full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 6.0),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
