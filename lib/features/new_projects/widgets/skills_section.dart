import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/core/styles.dart';
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key, required this.skills});
final List<String>skills;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'project_card_offer.skills'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((s) => _buildSkillChip(s)).toList(),
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
          const Icon(Icons.tag, color: Colors.white, size: 14.0),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
