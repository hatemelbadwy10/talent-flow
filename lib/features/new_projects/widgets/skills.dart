import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

/// A reusable form field for selecting a list of skills with type-ahead suggestions.
///
/// This widget displays a label, a list of selected skills as dismissible chips,
/// an input field for finding new skills, and a helper text below.
class SkillsSelectionField extends StatefulWidget {
  // You can add more properties here to customize the widget further,
  // such as an `onChanged` callback to get the list of selected skills.
  const SkillsSelectionField({super.key});

  @override
  State<SkillsSelectionField> createState() => _SkillsSelectionFieldState();
}

class _SkillsSelectionFieldState extends State<SkillsSelectionField> {
  // Controller for the text input field.
  final TextEditingController _controller = TextEditingController();

  // A list to hold the skills the user has selected.
  final List<String> _selectedSkills = [
    'فوتوشوب',
    'لغة عربية',
    'تصميم جرافيك',
  ];

  // A sample list of available skills for suggestions.
  // In a real app, this would likely come from an API.
  final List<String> _availableSkills = [
    'فوتوشوب',
    'تصميم جرافيك',
    'لغة عربية',
    'مونتاج',
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX Design',
    'Laravel',
    'PHP',
    'JavaScript',
  ];

  /// Fetches skill suggestions based on the user's input.
  Future<List<String>> _getSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }

    // Filter the available skills to find matches that haven't already been selected.
    return _availableSkills
        .where((skill) =>
    skill.toLowerCase().contains(pattern.toLowerCase()) &&
        !_selectedSkills.contains(skill))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Using Directionality to ensure proper layout for RTL languages.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: The label with a red asterisk.
          RichText(
            text: const TextSpan(
              text: 'المهارات',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                // Ensure you have the right font in your project
                fontFamily: 'IBMPlexSansArabic',
              ),
              children: <TextSpan>[
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Section 2: The input field container.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display selected skills as chips in a Wrap layout.
                Wrap(
                  spacing: 8.0, // Horizontal gap between chips
                  runSpacing: 4.0, // Vertical gap between chip lines
                  children: _selectedSkills.map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(color: Colors.black54)),
                      backgroundColor: Colors.grey.shade200,
                      deleteIconColor: Colors.grey.shade600,
                      onDeleted: () {
                        setState(() {
                          _selectedSkills.remove(skill);
                        });
                      },
                    );
                  }).toList(),
                ),
                // The TypeAhead field for entering new skills.
                TypeAheadField<String>(
                  controller: _controller,
                  // Configure the appearance of the text field.
                  builder: (context, controller, focusNode) => TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    decoration: const InputDecoration(
                      // Remove the border from the inner TextField.
                      border: InputBorder.none,
                      hintText: 'ابحث عن المهارات',
                    ),
                  ),
                  // The function that provides suggestions.
                  suggestionsCallback: _getSuggestions,
                  // Defines how each suggestion item in the list is built.
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  // What happens when a user taps a suggestion.
                  onSelected: (suggestion) {
                    setState(() {
                      // Add the skill if it's not already in the list.
                      if (!_selectedSkills.contains(suggestion)) {
                        _selectedSkills.add(suggestion);
                      }
                      // Clear the text field for the next input.
                      _controller.clear();
                    });
                  },
                  // UI to show when no suggestions are found.
                  emptyBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'لا توجد مهارات مطابقة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Section 3: The helper text below the field.
          Text(
            'حدد أهم المهارات المطلوبة لتنفيذ مشروعك.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}