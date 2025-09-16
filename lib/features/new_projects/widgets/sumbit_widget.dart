import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_bloc.dart';

import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../bloc/add_project_event.dart';
class SubmitWidget extends StatelessWidget {
  const SubmitWidget({super.key, required this.formKey});
final GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context) {
   return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: context.read<AddProjectBloc>().state.isSubmitting
            ? null
            : () {
          if (formKey.currentState!.validate()) {
            context
                .read<AddProjectBloc>()
                .add(SubmitProject());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Styles.PRIMARY_COLOR,
          padding:
          const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      child: context.read<AddProjectBloc>().state.isSubmitting
            ? const CircularProgressIndicator(
            color: Colors.white)
            : Text(
          'add_project.submit_project'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
