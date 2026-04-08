import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/app_currency.dart';
import 'package:talent_flow/app/core/app_core.dart';
import 'package:talent_flow/app/core/app_notification.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/add_project_event.dart';
import 'package:talent_flow/features/new_projects/widgets/file_upload_section.dart';
import 'package:talent_flow/features/setting/bloc/create_contract_bloc.dart';
import 'package:talent_flow/features/setting/bloc/create_contract_event.dart';
import 'package:talent_flow/features/setting/bloc/create_contract_state.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';
import 'package:talent_flow/features/setting/model/create_contract_page_info_model.dart';
import 'package:talent_flow/features/setting/model/create_contract_request_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/helpers/date_time_picker.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

class CreateContractScreen extends StatefulWidget {
  const CreateContractScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _durationController = TextEditingController();
  final _termsController = TextEditingController();
  final _notesController = TextEditingController();
  final _filesDescriptionController = TextEditingController();
  late final AddProjectBloc _addProjectBloc;
  late final CreateContractBloc _createContractBloc;

  int? get _projectId {
    final value =
        widget.arguments?['projectId'] ?? widget.arguments?['project_id'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  int? get _conversationId {
    final value = widget.arguments?['conversationId'] ??
        widget.arguments?['conversation_id'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  int? get _userId {
    final value =
        widget.arguments?['freelancerId'] ?? widget.arguments?['user_id'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  int? get _contractId {
    final value =
        widget.arguments?['contractId'] ?? widget.arguments?['contract_id'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool get _isEditMode => _contractId != null;

  ContractModel? get _initialContract {
    final value = widget.arguments?['contract'];
    return value is ContractModel ? value : null;
  }

  @override
  void initState() {
    super.initState();
    _addProjectBloc = AddProjectBloc(repository: sl());
    _createContractBloc = CreateContractBloc(sl());
    _hydrateFromInitialContract();
    final projectId = _projectId;
    if (projectId != null) {
      _createContractBloc.add(
        LoadCreateContractPageInfo(projectId: projectId),
      );
    }
  }

  @override
  void dispose() {
    _addProjectBloc.close();
    _createContractBloc.close();
    _contractNameController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _durationController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    _filesDescriptionController.dispose();
    super.dispose();
  }

  void _applyPageInfo(CreateContractPageInfoModel pageInfo) {
    void assignIfEmpty(TextEditingController controller, String? value) {
      if (controller.text.trim().isNotEmpty) {
        return;
      }
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) {
        controller.text = text;
      }
    }

    assignIfEmpty(_contractNameController, pageInfo.contractName);
    assignIfEmpty(_dateController, pageInfo.contractDate);
    assignIfEmpty(_costController, pageInfo.agreedCost);
    assignIfEmpty(_durationController, pageInfo.durationValue);
    assignIfEmpty(_termsController, pageInfo.contractTerms);
    assignIfEmpty(_notesController, pageInfo.additionalNotes);
    assignIfEmpty(_filesDescriptionController, pageInfo.filesDescription);

    final filesDescription = _filesDescriptionController.text.trim();
    if (filesDescription.isNotEmpty) {
      _addProjectBloc.add(
        UpdateFilesDescription(filesDescription: filesDescription),
      );
    }
  }

  void _hydrateFromInitialContract() {
    final contract = _initialContract;
    if (contract == null) {
      return;
    }

    void assign(TextEditingController controller, String? value) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) {
        controller.text = text;
      }
    }

    assign(_contractNameController, contract.title);
    assign(_dateController, _normalizeInitialDate(contract.date));
    assign(_costController, contract.suggestedPaymentAmount);
    assign(_durationController, _extractDigits(contract.duration));
    assign(_termsController, contract.terms);
    assign(_notesController, contract.rejectReason);
  }

  String _extractDigits(String? value) {
    final source = value?.trim() ?? '';
    if (source.isEmpty) {
      return '';
    }
    final match = RegExp(r'\d+').firstMatch(source);
    return match?.group(0) ?? source;
  }

  String? _normalizeInitialDate(String? value) {
    final source = value?.trim() ?? '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(source)) {
      return source;
    }
    return null;
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

  Future<void> _submit() async {
    final projectId = _projectId;
    if (projectId == null) {
      _showError('Project id is missing');
      return;
    }
    final userId = _userId;
    if (userId == null) {
      _showError('User id is missing');
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final request = CreateContractRequestModel(
      projectId: projectId,
      userId: userId,
      conversationId: _conversationId,
      date: _dateController.text.trim(),
      title: _contractNameController.text.trim(),
      budget: _costController.text.trim(),
      duration: _durationController.text.trim(),
      terms: _termsController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      files: List.of(_addProjectBloc.state.files),
    );
    _createContractBloc.add(
      SubmitCreateContract(
        request: request,
        contractId: _contractId,
      ),
    );
  }

  void _showError(String message) {
    AppCore.showSnackBar(
      notification: AppNotification(
        message: message,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _addProjectBloc),
        BlocProvider.value(value: _createContractBloc),
      ],
      child: BlocConsumer<CreateContractBloc, CreateContractState>(
        listener: (context, state) {
          final pageInfo = state.pageInfo;
          if (pageInfo != null) {
            _applyPageInfo(pageInfo);
          }

          if ((state.errorMessage ?? '').isNotEmpty) {
            _showError(state.errorMessage!);
          } else if ((state.successMessage ?? '').isNotEmpty) {
            AppCore.showSnackBar(
              notification: AppNotification(
                message: state.successMessage!,
                backgroundColor: Colors.green.shade50,
                borderColor: Colors.green.shade200,
              ),
            );
            context.read<CreateContractBloc>().add(
                  const ClearCreateContractFeedback(),
                );
            CustomNavigator.pop(result: true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            appBar: CustomAppBar(
              title: _isEditMode
                  ? 'create_contract_screen.edit_title'.tr()
                  : 'create_contract_screen.title'.tr(),
              centerTitle: true,
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _projectInfoCard(state),
                    const SizedBox(height: 14),
                    _contractFormCard(),
                    const SizedBox(height: 14),
                    _conditionsCard(state),
                    const SizedBox(height: 18),
                    _submitButton(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _projectInfoCard(CreateContractState state) {
    final pageInfo = state.pageInfo;
    final projectTitle = pageInfo?.projectTitle?.trim().isNotEmpty == true
        ? pageInfo!.projectTitle!
        : 'create_contract_screen.project_title_value'.tr();
    final projectOwner = pageInfo?.projectOwner?.trim().isNotEmpty == true
        ? pageInfo!.projectOwner!
        : 'create_contract_screen.project_owner_value'.tr();
    final currentBudget = pageInfo?.currentBudget?.trim().isNotEmpty == true
        ? pageInfo!.currentBudget!
        : 'create_contract_screen.current_budget_value'.tr();
    final currentDuration = pageInfo?.currentDuration?.trim().isNotEmpty == true
        ? pageInfo!.currentDuration!
        : 'create_contract_screen.current_duration_value'.tr();

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
                if (state.isLoadingPageInfo) ...[
                  const LinearProgressIndicator(
                    color: Styles.PRIMARY_COLOR,
                    minHeight: 3,
                  ),
                  const SizedBox(height: 12),
                ],
                if ((state.errorMessage ?? '').isNotEmpty &&
                    pageInfo == null) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _infoRow(
                  'create_contract_screen.project_title'.tr(),
                  projectTitle,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.project_owner'.tr(),
                  projectOwner,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.current_budget'.tr(),
                  currentBudget,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'create_contract_screen.current_duration'.tr(),
                  currentDuration,
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
            formattedType: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            suffixText: AppCurrency.code,
          ),
          _field(
            controller: _durationController,
            label: 'create_contract_screen.duration'.tr(),
            inputType: TextInputType.number,
            formattedType: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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
    List<TextInputFormatter>? formattedType,
    String? suffixText,
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
      formattedType: formattedType,
      sufWidget: suffixText == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(
                suffixText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Styles.HINT_COLOR,
                ),
              ),
            ),
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

  Widget _conditionsCard(CreateContractState state) {
    final pageInfo = state.pageInfo;
    final talentRatio =
        pageInfo?.talentPercentageOfContracts?.trim().isNotEmpty == true
            ? pageInfo!.talentPercentageOfContracts!
            : null;
    final terminationConditions =
        pageInfo?.terminationConditions?.trim().isNotEmpty == true
            ? pageInfo!.terminationConditions!
            : null;
    final conflictPolicy = pageInfo?.conflictPolicy?.trim().isNotEmpty == true
        ? pageInfo!.conflictPolicy!
        : null;

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
            'create_contract_screen.talent_flow_percentage'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (talentRatio != null) ...[
            const SizedBox(height: 6),
            Text(
              talentRatio,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Styles.PRIMARY_COLOR,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (terminationConditions != null) ...[
            Html(data: terminationConditions),
            const SizedBox(height: 8),
          ],
          if (conflictPolicy != null) ...[
            Html(data: conflictPolicy),
          ],
          if (terminationConditions == null && conflictPolicy == null)
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

  Widget _submitButton(CreateContractState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Styles.PRIMARY_COLOR,
          disabledBackgroundColor: Styles.PRIMARY_COLOR.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditMode
                    ? 'create_contract_screen.update_button'.tr()
                    : 'create_contract_screen.create_button'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
