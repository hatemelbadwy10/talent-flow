import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/core/styles.dart';
import '../bloc/portofilo_form_bloc.dart';
import '../../../app/core/app_state.dart';
import '../../../components/custom_text_form_field.dart';

class PortfolioUploadForm extends StatefulWidget {
  const PortfolioUploadForm({super.key});

  @override
  State<PortfolioUploadForm> createState() => _PortfolioUploadFormState();
}

class _PortfolioUploadFormState extends State<PortfolioUploadForm> {
  final List<TextEditingController> _titleControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _descriptionControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _featuresControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _linkControllers =
      List.generate(3, (_) => TextEditingController());

  @override
  void dispose() {
    for (int i = 0; i < 3; i++) {
      _titleControllers[i].dispose();
      _descriptionControllers[i].dispose();
      _featuresControllers[i].dispose();
      _linkControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PortfolioFormBloc, AppState>(
      listener: (context, state) {
        if (state is Done && state.reload == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("All portfolios submitted successfully!")),
          );
        }
      },
      child: BlocBuilder<PortfolioFormBloc, AppState>(
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! Done || state.data is! PortfolioFormsState) {
            return const Center(child: Text("Initializing form..."));
          }

          final formState = state.data as PortfolioFormsState;

          for (int i = 0; i < 3; i++) {
            final formData = formState.forms[i];
            if (_titleControllers[i].text != formData.title) {
              _titleControllers[i].text = formData.title;
            }
            if (_descriptionControllers[i].text != formData.description) {
              _descriptionControllers[i].text = formData.description;
            }
            if (_featuresControllers[i].text != formData.features) {
              _featuresControllers[i].text = formData.features;
            }
            if (_linkControllers[i].text != formData.clientLink) {
              _linkControllers[i].text = formData.clientLink;
            }
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                ...List.generate(
                    3,
                    (index) => _buildCollapsibleFormCard(
                        context: context,
                        formIndex: index,
                        formState: formState)),
                const SizedBox(height: 24),
                _buildTermsConfirmationCard(context, formState),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<PortfolioFormBloc>()
                        .add(SubmitAllPortfolios()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.PRIMARY_COLOR,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("أضف كل الاعمال",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- NEW WIDGET: The grey card for terms confirmation ---
  Widget _buildTermsConfirmationCard(
      BuildContext context, PortfolioFormsState formState) {
    final bloc = context.read<PortfolioFormBloc>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // The light grey background
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const Text(
            'تأكيد الشروط',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 16.0),
          _buildSingleCheckboxRow(
            text: "جميع الاعمال من تنفيذى ولدى صلاحية لنشرها.",
            value: formState.termsOneAccepted,
            onChanged: (newValue) =>
                bloc.add(UpdateSingleTerm(termIndex: 1, isAccepted: newValue!)),
          ),
          const SizedBox(height: 12.0),
          _buildSingleCheckboxRow(
            text:
                "أعلم انه سيتم ايقاف حسابى ان استخدمت اعمال تنتهك حقوق الاخرين.",
            value: formState.termsTwoAccepted,
            onChanged: (newValue) =>
                bloc.add(UpdateSingleTerm(termIndex: 2, isAccepted: newValue!)),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCheckboxRow(
      {required String text,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    return InkWell(
      onTap: () => () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Styles.PRIMARY_COLOR,
              side: BorderSide(color: Colors.grey.shade400, width: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleFormCard(
      {required BuildContext context,
      required int formIndex,
      required PortfolioFormsState formState}) {
    final bool isExpanded = formState.expandedFormIndex == formIndex;
    final bloc = context.read<PortfolioFormBloc>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => bloc.add(ExpandForm(formIndex: formIndex)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("العمل ${formIndex + 1} من 3",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _buildFormBody(context, formIndex)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBody(BuildContext context, int formIndex) {
    final bloc = context.read<PortfolioFormBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: "عنوان العمل",
            hint: "اكتب هنا اسم العمل",
            controller: _titleControllers[formIndex],
            onChanged: (value) => bloc.add(UpdateFormField(
                formIndex: formIndex, fieldName: 'title', value: value)),
          ),
          const SizedBox(height: 16.0),
          _buildFileUploadField(
              label: "صورة مصغرة",
              buttonText: "اضغط هنا للتحميل أو اسحب",
              description: "SVG, PNG, JPG or GIF (max. 800x400px)"),
          CustomTextField(
            label: "وصف العمل",
            hint: "اكتب وصف للعمل.........",
            controller: _descriptionControllers[formIndex],
            maxLines: 4,
            onChanged: (value) => bloc.add(UpdateFormField(
                formIndex: formIndex, fieldName: 'description', value: value)),
          ),
          const SizedBox(height: 16.0),
          CustomTextField(
            label: "ميزات العمل",
            hint: "أضف وصفا دقيقا يوضح ميزات العمل",
            controller: _featuresControllers[formIndex],
            maxLines: 3,
            onChanged: (value) => bloc.add(UpdateFormField(
                formIndex: formIndex, fieldName: 'features', value: value)),
          ),
          const SizedBox(height: 16.0),
          _buildFileUploadField(
              label: "صور وملفات العمل",
              buttonText: "اضغط هنا للتحميل أو اسحب",
              description: "أضف صور أو ملفات بحد أقصى 20 مرفق"),
          CustomTextField(
            label: "رابط المعاينه",
            hint: "ادخل الرابط هنا",
            controller: _linkControllers[formIndex],
            onChanged: (value) => bloc.add(UpdateFormField(
                formIndex: formIndex, fieldName: 'clientLink', value: value)),
          ),
          const SizedBox(height: 16.0),
          _buildDropdownField(
              label: "تاريخ الإنجاز", hintText: "اختر تاريخ الإنجاز"),
        ],
      ),
    );
  }

  Widget _buildFileUploadField(
      {required String label,
      required String buttonText,
      required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300, width: 1)),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    color: Colors.grey.shade500, size: 32),
                const SizedBox(height: 8.0),
                Text(buttonText,
                    style: const TextStyle(
                        color: Styles.PRIMARY_COLOR,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(description,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildDropdownField(
      {required String label, required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hintText, style: TextStyle(color: Colors.grey.shade500)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
