import 'package:flutter/material.dart';
import 'package:talent_flow/components/grid_list_animator.dart';

import '../../../app/core/styles.dart';

class ProjectDetailsCard extends StatelessWidget {
  const ProjectDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16.0),
            _buildProjectInfo(),
            const SizedBox(height: 16.0),
            _buildSkillsSection(),
            const Divider(height: 32.0),
            _buildUserInfo(),
            const Divider(height: 32.0),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  /// Builds the top header section with the title and meta info.
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "بطاقة المشروع",
          style: TextStyle(
            // NOTE: Add 'IBM Plex Sans Arabic' to your project for the exact font.
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text("منذ 42 دقيقة", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(width: 12),
            const Icon(Icons.visibility_outlined, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text("54", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  /// Builds the main project information section (Status, Budget, Duration).
  Widget _buildProjectInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("حالة المشروع",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black)),
            const SizedBox(
              width: 46,
            ),
_projectStatus("status")          ],
        ),
        const SizedBox(height: 8),
        _buildKeyValueRow("الميزانية", const Text("\$100.00 - \$50.00")),
        const SizedBox(height: 8),
        _buildKeyValueRow("مدة التنفيذ", const Text("15 يوماً")),
      ],
    );
  }

  /// Builds the skills section with a title and a wrap of skill chips.
  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المهارات",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) => _buildSkillChip("فوتوشوب"),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Styles.PRIMARY_COLOR,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.tag,
            color: Colors.white,
            size: 14.0,
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 10, // matches your Figma typography
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the user info section with avatar, name, and registration date.
  Widget _buildUserInfo() {
    return Column(
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12'), // Placeholder
            ),
            SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("راشد حمدان",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("مسوق رقمي", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildKeyValueRow("تاريخ التسجيل", const Text("20 ابريل 2022")),
      ],
    );
  }

  /// Builds the final statistics section.
  Widget _buildStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKeyValueRow(
            "معدل التوظيف",
            _projectStatus("status")),
        const SizedBox(height: 12),
        _buildKeyValueRow("المشاريع المفتوحة",
            const Text("1", style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        _buildKeyValueRow("مشاريع قيد التنفيذ",
            const Text("0", style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        _buildKeyValueRow("التواصلات الجارية",
            const Text("0", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  /// A helper to create a row with a key (title) on the left and a value widget on the right.
  Widget _buildKeyValueRow(String key, Widget valueWidget) {
    return Row(
      children: [
        Text(key, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(
          width: 46,
        ),
        valueWidget,
      ],
    );
  }

  // /// A helper widget to create the green skill chips.
  // Widget _buildSkillChip(String label) {
  //   return Container(
  //     height: 13,
  //     width: 38,
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
  //     decoration: BoxDecoration(
  //       color: Styles.PRIMARY_COLOR,
  //       borderRadius: BorderRadius.circular(20.0),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.tag,
  //           color: Colors.white,
  //           size: 16.0,
  //         ),
  //         const SizedBox(width: 8.0),
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  _projectStatus(String status) {
    return Container(
      height: 28,
      width: 85,
      decoration: BoxDecoration(
        color: const Color(0xff00AC25),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Center(
          child: Text(
        'مفتوح',
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}
