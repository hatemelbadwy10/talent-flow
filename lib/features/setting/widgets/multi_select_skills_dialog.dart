import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/core/styles.dart';

class MultiSelectSkillsDialog extends StatefulWidget {
  final List<String> allSkills;
  final List<String> initialSelectedSkills;

  const MultiSelectSkillsDialog({
    required this.allSkills,
    required this.initialSelectedSkills,
    super.key,
  });

  @override
  State<MultiSelectSkillsDialog> createState() =>
      _MultiSelectSkillsDialogState();
}

class _MultiSelectSkillsDialogState extends State<MultiSelectSkillsDialog> {
  final List<String> _tempSelectedSkills = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedSkills.addAll(widget.initialSelectedSkills);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSkills = widget.allSkills.where((skill) {
      if (_searchQuery.trim().isEmpty) {
        return true;
      }
      return skill.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("edit_profile.select_skills".tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "search_hint".tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            Flexible(
              child: filteredSkills.isEmpty
                  ? Center(
                      child: Text(
                        "No results",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : SingleChildScrollView(
                      child: ListBody(
                        children: filteredSkills.map((skill) {
                          return CheckboxListTile(
                            checkColor: Styles.WHITE_COLOR,
                            activeColor: Styles.PRIMARY_COLOR,
                            value: _tempSelectedSkills.contains(skill),
                            title: Text(skill),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _tempSelectedSkills.add(skill);
                                } else {
                                  _tempSelectedSkills.remove(skill);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            "edit_profile.cancel".tr(),
            style: const TextStyle(color: Styles.LOGOUT_COLOR),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            "edit_profile.select".tr(),
            style: const TextStyle(color: Styles.PRIMARY_COLOR),
          ),
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedSkills);
          },
        ),
      ],
    );
  }
}
