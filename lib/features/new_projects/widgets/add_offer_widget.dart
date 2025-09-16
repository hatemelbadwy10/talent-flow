import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../components/custom_button.dart';
import '../../../navigation/routes.dart'; // Add this import for navigation
import '../bloc/new_projects_bloc.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'dismiss'.tr(),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
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
      Click(arguments: {
        "projectId": widget.id,
        "description": description,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewProjectsBloc, AppState>(
      listener: (context, state) {
        if (state is Loading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is Done) {
          setState(() {
            _isLoading = false;
          });
          // Show success message
          _showSuccessSnackBar('add_offer.success'.tr());

          // Navigate to navbar/main screen after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            // Option 1: Navigate to navbar (adjust route name as needed)
            CustomNavigator.push(Routes.navBar,clean: true);

            // Option 2: If you want to pop to root and go to a specific tab
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //   Routes.navbar,
            //   (route) => false,
            // );
          });
        } else if (state is Error) {
          setState(() {
            _isLoading = false;
          });
          // Show error message
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
              // You might want to add a loading indicator inside the button
              isLoading: _isLoading

            ),
          ],
        ),
      ),
    );
  }
}