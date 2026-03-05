import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_bloc.dart';
import 'package:talent_flow/features/new_projects/widgets/file_upload_section.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _termsController = TextEditingController();
  final _notesController = TextEditingController();
  final _filesDescriptionController = TextEditingController();

  @override
  void dispose() {
    _contractNameController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    _filesDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        label: 'create_contract_screen.date'.tr(),
        startDateTime: DateTime.now(),
        minDateTime: DateTime(1900),
        valueChanged: (value) {
          final month = value.month.toString().padLeft(2, '0');
          final day = value.day.toString().padLeft(2, '0');
          _dateController.text = '${value.year}-$month-$day';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProjectBloc(repository: sl()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'create_contract_screen.title'.tr(),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _projectInfoCard(),
                const SizedBox(height: 14),
                _contractFormCard(),
                const SizedBox(height: 14),
                _conditionsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _projectInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Styles.PRIMARY_COLOR,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'create_contract_screen.project_info'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _infoRow(
                  'create_contract_screen.project_title'.tr(),
                  'create_contract_screen.project_title_value'.tr(),
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.project_owner'.tr(),
                  'create_contract_screen.project_owner_value'.tr(),
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.current_budget'.tr(),
                  'create_contract_screen.current_budget_value'.tr(),
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.current_duration'.tr(),
                  'create_contract_screen.current_duration_value'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _contractFormCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _field(
            controller: _contractNameController,
            label: 'create_contract_screen.contract_name'.tr(),
          ),
          _field(
            controller: _dateController,
            label: 'create_contract_screen.date'.tr(),
            readOnly: true,
            onTap: _pickDate,
          ),
          _field(
            controller: _costController,
            label: 'create_contract_screen.agreed_cost'.tr(),
            inputType: TextInputType.number,
          ),
          _field(
            controller: _termsController,
            label: 'create_contract_screen.contract_terms'.tr(),
            maxLines: 3,
          ),
          _field(
            controller: _notesController,
            label: 'create_contract_screen.additional_notes'.tr(),
            maxLines: 3,
            required: false,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'create_contract_screen.contract_files'.tr(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FileUploadSection(
            filesDescriptionController: _filesDescriptionController,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
    bool required = true,
    TextInputType? inputType,
    VoidCallback? onTap,
  }) {
    return CustomTextField(
      controller: controller,
      withLabel: true,
      label: label,
      hint: label,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      inputType: inputType,
      validate: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'create_contract_screen.required_field'.tr();
              }
              return null;
            }
          : null,
    );
  }

  Widget _conditionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'create_contract_screen.talent_flow_ratio'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'create_contract_screen.conditions_text'.tr(),
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}
