import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
class SingleSelectDialog extends StatefulWidget {
  final String title;
  final Map<String, String> options; // Map of {id: name}
  final String? initialSelectedId;

  const SingleSelectDialog({
    Key? key,
    required this.title,
    required this.options,
    this.initialSelectedId,
  }) : super(key: key);

  @override
  _SingleSelectDialogState createState() => _SingleSelectDialogState();
}

class _SingleSelectDialogState extends State<SingleSelectDialog> {
  String? _tempSelectedId;

  @override
  void initState() {
    super.initState();
    _tempSelectedId = widget.initialSelectedId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.entries.map((entry) {
            final id = entry.key;
            final name = entry.value;
            return RadioListTile<String>(
              value: id,
              groupValue: _tempSelectedId,
              title: Text(name),
              onChanged: (String? selectedId) {
                setState(() {
                  _tempSelectedId = selectedId;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("cancel".tr()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("select".tr()),
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedId);
          },
        ),
      ],
    );
  }
}
