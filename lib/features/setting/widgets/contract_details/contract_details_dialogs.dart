import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/styles.dart';

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
  final _formKey = GlobalKey<FormState>();
  double _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFF5A623),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'contract_details_screen.hints.rating'.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E7683),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE7EDF3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final isActive = _rating >= starIndex;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = starIndex.toDouble();
                          });
                        },
                        visualDensity: VisualDensity.compact,
                        splashRadius: 22,
                        icon: Icon(
                          isActive
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF5A623),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_rating.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171717),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Styles.PRIMARY_COLOR,
                      inactiveTrackColor: const Color(0xFFD9E2EC),
                      thumbColor: Styles.PRIMARY_COLOR,
                      overlayColor:
                          Styles.PRIMARY_COLOR.withValues(alpha: 0.12),
                      trackHeight: 5,
                    ),
                    child: Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: _rating,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'contract_details_screen.hints.review_comment'.tr(),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE7EDF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE7EDF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Styles.PRIMARY_COLOR,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'contract_details_screen.validation.required'.tr();
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: const Color(0xFF6E7683),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE1E7EF)),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('contract_details_screen.common.cancel'.tr()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) {
                      return;
                    }
                    Navigator.of(context).pop(
                      ReviewDialogResult(
                        comment: _commentController.text.trim(),
                        rating: _rating.toStringAsFixed(1),
                      ),
                    );
                  },
                  child: Text('contract_details_screen.common.submit'.tr()),
                ),
              ),
            ],
          ),
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
