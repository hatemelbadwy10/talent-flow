import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextActionDialog extends StatefulWidget {
  const TextActionDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.submitText,
  });

  final String title;
  final String hint;
  final String submitText;

  @override
  State<TextActionDialog> createState() => _TextActionDialogState();
}

class _TextActionDialogState extends State<TextActionDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'contract_details_screen.validation.required'.tr();
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('contract_details_screen.common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: Text(widget.submitText),
        ),
      ],
    );
  }
}

class ReviewActionDialog extends StatefulWidget {
  const ReviewActionDialog({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ReviewActionDialog> createState() => _ReviewActionDialogState();
}

class _ReviewActionDialogState extends State<ReviewActionDialog> {
  final _commentController = TextEditingController();
  final _ratingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'contract_details_screen.hints.review_comment'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'contract_details_screen.validation.required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ratingController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              decoration: InputDecoration(
                hintText: 'contract_details_screen.hints.rating'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'contract_details_screen.validation.required'.tr();
                }

                final rating = double.tryParse(value!.trim());
                if (rating == null || rating < 0 || rating > 5) {
                  return 'contract_details_screen.validation.rating'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('contract_details_screen.common.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) {
              return;
            }
            Navigator.of(context).pop(
              ReviewDialogResult(
                comment: _commentController.text.trim(),
                rating: _ratingController.text.trim(),
              ),
            );
          },
          child: Text('contract_details_screen.common.submit'.tr()),
        ),
      ],
    );
  }
}

class ReviewDialogResult {
  const ReviewDialogResult({
    required this.comment,
    required this.rating,
  });

  final String comment;
  final String rating;
}
