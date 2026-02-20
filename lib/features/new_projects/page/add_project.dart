import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_state.dart';
import '../../../app/core/app_event.dart';
import '../../../data/config/di.dart';
import '../bloc/add_project_bloc.dart';
import '../bloc/add_project_state.dart';
import '../bloc/selection_option_bloc.dart';
import '../model/selection_option_model.dart';
import '../widgets/advanced_widget.dart';
import '../widgets/budget_duration.dart';
import '../widgets/description_widget.dart';
import '../widgets/file_upload_section.dart';
import '../widgets/project_title_widget.dart';
import '../widgets/skills.dart';
import '../widgets/specialization_dropdown.dart';
import '../widgets/sumbit_widget.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _filesDescriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _requiredToBeRecivedController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _filesDescriptionController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddProjectBloc(repository: sl()),
        ),
        BlocProvider(
          create: (context) => SelectionOptionBloc(sl())..add(Add()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AddProjectBloc, AddProjectState>(
            listener: (context, state) {
              if (state.isSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('add_project.success_message'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: Text('add_project.add_project'.tr()),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: BlocBuilder<SelectionOptionBloc, AppState>(
            builder: (context, selectOptionsState) {
              if (selectOptionsState is Loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (selectOptionsState is Error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${selectOptionsState}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SelectionOptionBloc>().add(Add());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (selectOptionsState is! Done) {
                return const SizedBox.shrink();
              }

              return BlocBuilder<AddProjectBloc, AddProjectState>(
                builder: (context, projectState) {
                  final selectionModel = (selectOptionsState).model as SelectionModel;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SpecializationDropdown(
                              specializations: selectionModel.specializations,
                            ),
                            const SizedBox(height: 24),

                            ProjectTitleField(controller: _titleController),
                            const SizedBox(height: 24),

                            ProjectDescriptionField(controller: _descriptionController),
                            const SizedBox(height: 24),

                            SkillsDropdown(
                              availableSkills: selectionModel.skills,
                            ),
                            const SizedBox(height: 24),

                            BudgetField(controller: _budgetController),
                            const SizedBox(height: 24),

                            DurationField(controller: _durationController),
                            const SizedBox(height: 24),

                            FileUploadSection(
                              filesDescriptionController: _filesDescriptionController,

                            ),
                            const SizedBox(height: 24),

                            AdvancedSettings(
                              requiredToBeReceivedContr: _requiredToBeRecivedController,
                            ),
                            const SizedBox(height: 32),

                            SubmitWidget(formKey: _formKey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}