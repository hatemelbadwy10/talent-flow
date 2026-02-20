import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/core/styles.dart';

class AddQuestionDialog extends StatefulWidget {
  final Function(String question, bool isRequired) onAdd;

  const AddQuestionDialog({super.key, required this.onAdd});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog>
    with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  bool _isRequired = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();

    _questionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    color: Styles.PRIMARY_COLOR,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'add_project.add_question'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color:Styles.PRIMARY_COLOR,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Styles.LOGOUT_COLOR,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question input
              Text(
                'add_project.question_text'.tr(),
                style: const TextStyle(
                  color: Styles.PRIMARY_COLOR,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionController,
                maxLines: 3,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: 'add_project.question_hint'.tr(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Required checkbox
              CheckboxListTile(
                value: _isRequired,
                onChanged: (value) => setState(() => _isRequired = value ?? false),
                title: Text(
                  'add_project.mandatory_question'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'add_project.mandatory_question_hint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Styles.APP_BAR_BACKGROUND_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Styles.PRIMARY_COLOR),
                      ),
                      child: Text(
                        'add_project.cancel'.tr(),
                        style: const TextStyle(
                          color: Styles.SUBTITLE,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _questionController.text.isEmpty
                          ? null
                          : () {
                        widget.onAdd(
                          _questionController.text.trim(),
                          _isRequired,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'add_project.add'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
