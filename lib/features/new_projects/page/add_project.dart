import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../components/dynamic_drop_down_button.dart';
import '../widgets/skills.dart';

class DropdownItem {
  final String tag;
  DropdownItem(this.tag);
}

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();

  bool _isQuestionMandatory = false;
  final List<DropdownItem> _budgetItems = [
    DropdownItem('\$250 - \$500'),
    DropdownItem('\$500 - \$1000'),
    DropdownItem('\$1000 - \$2500'),
  ];
  final List<DropdownItem> _durationItems = [
    DropdownItem('أقل من أسبوع'),
    DropdownItem('أسبوع - أسبوعين'),
    DropdownItem('أسبوعين - شهر'),
    DropdownItem('أكثر من شهر'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: const Text("إضافة مشروع"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- All your previous form fields are here ---
                  _buildSectionLabel("عنوان المشروع"),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: "عنوان المشروع",
                    hint: "مثال: تصميم شعار لشركة تقنية",
                    validate: (value) {
                      if (value == null || value.isEmpty) return 'الحقل مطلوب';
                      return null;
                    },
                  ),
                  _buildHelperText("أدرج عنوانا موجزا يصف مشروعك بشكل دقيق."),
                  const SizedBox(height: 24),
                  _buildSectionLabel("وصف المشروع", isRequired: true, trailing: TextButton(onPressed: () {}, child: const Text("إعادة تعيين", style: TextStyle(color: Colors.green)))),
                  const SizedBox(height: 8),
                  CustomTextField(label: "وصف المشروع", minLines: 4, maxLines: 6, hint: "ادخل وصف المشروع هنا...", validate: (value) { if (value == null || value.isEmpty) return 'الحقل مطلوب'; return null; }),
                  _buildHelperText("أدخل وصفاً مفصلاً لمشروعك وأرفق أمثلة لما تريد إن أمكن."),
                  const SizedBox(height: 24),
                  const SkillsSelectionField(),
                  const SizedBox(height: 24),
                  _buildSectionLabel("الميزانية المتوقعة", isRequired: true),
                  const SizedBox(height: 8),
                  DynamicDropDownButton(items: _budgetItems, name: "اختر الميزانية", validation: (value) { if (value == null) return 'الرجاء اختيار الميزانية'; return null; }),
                  _buildHelperText("اختر ميزانية مناسبة لتحصل على عروض جيدة."),
                  const SizedBox(height: 24),
                  _buildSectionLabel("المدة المتوقعة للتسليم", isRequired: true),
                  const SizedBox(height: 8),
                  DynamicDropDownButton(items: _durationItems, name: "اختر المدة", validation: (value) { if (value == null) return 'الرجاء اختيار المدة'; return null; }),
                  const SizedBox(height: 24),

                  _buildSectionLabel("ملفات توضيحية"),
                  const SizedBox(height: 8),
                  _buildFileUploadSection(),
                  _buildHelperText("أضف صورة جذابة معبرة عن العمل."),
                  const SizedBox(height: 24),


                  _buildAdvancedSettings(),
                  const SizedBox(height: 32),

                  // --- Final Submit Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Process and submit the form data
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.PRIMARY_COLOR, // Use your style's primary color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("أضف المشروع الآن", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the file upload dropzone.
  Widget _buildFileUploadSection() {
    return DottedBorder(
      color: Colors.grey.shade400,
      strokeWidth: 1.5,
      dashPattern: const [8, 4],
      radius: const Radius.circular(8),
      borderType: BorderType.RRect,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade600, size: 40),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                text: 'اضغط هنا للتحميل',
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                children: [
                  TextSpan(
                    text: ' أو اسحب',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text("SVG, PNG, JPG or GIF (max. 800x400px)", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Builds the collapsible "Advanced Settings" section.
  Widget _buildAdvancedSettings() {
    return ExpansionTile(
      title: const Text("إعدادات متقدمة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      shape: const Border(), // Removes border when expanded
      collapsedShape: const Border(), // Removes border when collapsed
      children: [
        // --- Project Questions Section ---
        _buildSectionLabel("أسئلة المشروع", isRequired: true),
        const SizedBox(height: 8),
        CustomTextField(
          label: "",
          hint: "اكتب هنا اسم العمل",
          validate: (value) {
            // This validation could be conditional
            return null;
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _isQuestionMandatory,
                    onChanged: (bool? value) {
                      setState(() {
                        _isQuestionMandatory = value ?? false;
                      });
                    },
                  ),
                  const Text("سؤال إجباري"),
                ],
              ),
              TextButton(
                onPressed: () { /* TODO: Handle delete question */ },
                child: const Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        _buildHelperText("أضف الأسئلة التي تود أن يجيب عنها المستقلين أثناء تقديم عروضهم."),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () { /* TODO: Handle adding a new question */ },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("إضافة سؤال جديد", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- Your existing helper widgets ---
  Widget _buildSectionLabel(String text, {bool isRequired = false, Widget? trailing}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [ RichText(text: TextSpan(text: text, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500), children: <TextSpan>[if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold))])), if (trailing != null) trailing]);
  }
  Widget _buildHelperText(String text) {
    return Padding(padding: const EdgeInsets.only(top: 8.0, right: 4.0), child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)));
  }
}