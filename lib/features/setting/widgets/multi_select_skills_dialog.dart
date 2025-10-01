import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/core/styles.dart';
class MultiSelectSkillsDialog extends StatefulWidget {
  final List<String> allSkills;
  final List<String> initialSelectedSkills;

  const MultiSelectSkillsDialog({
    Key? key,
    required this.allSkills,
    required this.initialSelectedSkills,
  }) : super(key: key);

  @override
  _MultiSelectSkillsDialogState createState() => _MultiSelectSkillsDialogState();
}

class _MultiSelectSkillsDialogState extends State<MultiSelectSkillsDialog> {
  final List<String> _tempSelectedSkills = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedSkills.addAll(widget.initialSelectedSkills);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("edit_profile.select_skills".tr()),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.allSkills.map((skill) {
            return CheckboxListTile(
              checkColor: Styles.WHITE_COLOR,
              activeColor: Styles.PRIMARY_COLOR,
              value: _tempSelectedSkills.contains(skill),
              title: Text(skill),
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
      actions: <Widget>[
        TextButton(
          child: Text("edit_profile.cancel".tr(),style: TextStyle(color: Styles.LOGOUT_COLOR),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("edit_profile.select".tr(),style: const TextStyle(color: Styles.PRIMARY_COLOR),),
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedSkills);
          },
        ),
      ],
    );
  }
}