import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../components/custom_button.dart';
import '../../../navigation/routes.dart';
import '../bloc/new_projects_bloc.dart';
import '../bloc/new_projects_event.dart';
import '../bloc/new_projects_state.dart';

class AddOfferWidget extends StatefulWidget {
  final int id;
  const AddOfferWidget({super.key, required this.id});

  @override
  State<AddOfferWidget> createState() => _AddOfferWidgetState();
}

class _AddOfferWidgetState extends State<AddOfferWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.IN_ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Styles.ACTIVE,
        borderColor: Colors.transparent,
        isFloating: true,
      ),
    );
  }

  void _submitOffer() {
    final description = _controller.text.trim();
    if (description.isEmpty) {
      _showErrorSnackBar('add_offer.empty_description'.tr());
      return;
    }

    context.read<NewProjectsBloc>().add(
          ProjectOfferSubmitted(
            projectId: widget.id,
            description: description,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewProjectsBloc, NewProjectsState>(
      listener: (context, state) {
        if (state is OfferSubmissionInProgress) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is OfferSubmissionSuccess) {
          final successMessage = state.message?.trim().isNotEmpty == true
              ? state.message!
              : 'add_offer.success'.tr();
          setState(() {
            _isLoading = false;
          });
          _showSuccessSnackBar(successMessage);

          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            CustomNavigator.push(Routes.navBar, clean: true);
          });
        } else if (state is OfferSubmissionFailure) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('add_offer.error'.tr());
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_offer.title'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1, thickness: .5),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _controller,
              maxLines: 5,
              minLines: 3,
              hint: 'add_offer.hint'.tr(),
            ),
            SizedBox(height: 16.h),
            CustomButton(
                text: _isLoading ? 'loading'.tr() : 'submit_button'.tr(),
                isActive: !_isLoading,
                onTap: _isLoading ? null : _submitOffer,
                isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
