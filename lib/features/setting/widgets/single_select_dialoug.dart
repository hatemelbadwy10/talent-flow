import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SingleSelectDialog extends StatefulWidget {
  final String title;
  final Map<String, String> options; // Map of {id: name}
  final String? initialSelectedId;

  const SingleSelectDialog({
    required this.title,
    required this.options,
    this.initialSelectedId,
    super.key,
  });

  @override
  State<SingleSelectDialog> createState() => _SingleSelectDialogState();
}

class _SingleSelectDialogState extends State<SingleSelectDialog> {
  String? _tempSelectedId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedId = widget.initialSelectedId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.options.entries.where((entry) {
      if (_searchQuery.trim().isEmpty) {
        return true;
      }
      return entry.value.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(widget.title),
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
              child: filteredOptions.isEmpty
                  ? Center(
                      child: Text(
                        "No results",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : SingleChildScrollView(
                      child: ListBody(
                        children: filteredOptions.map((entry) {
                          final id = entry.key;
                          final name = entry.value;
                          final isSelected = _tempSelectedId == id;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(name),
                            trailing: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            onTap: () {
                              setState(() {
                                _tempSelectedId = id;
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
