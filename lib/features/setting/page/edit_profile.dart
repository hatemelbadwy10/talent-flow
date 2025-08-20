import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_text_form_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          "assets/images/Talent Flow logo 1 1.png",
          height: 35,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'تعديل الحساب',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const EditProfileForm(),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  // Controllers are managed inside the StatefulWidget.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _detailedBioController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _detailedBioController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Directionality widget ensures the layout is Right-to-Left (RTL).
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildNameFields(),
            _buildLabeledTextField("البريد الالكتروني",
                "ادخل البريد الالكتروني الخاص بك", _emailController),
            _buildDropdownField("التخصص", "اختر مجال عملك"),
            _buildDropdownField("المسمى الوظيفي", "اختر المسمى الوظيفي"),
            _buildLabeledTextField("نبذة تعريفية",
                "اكتب وصف تعريفي عن نفسك ........", _bioController,
                maxLines: 4),
            _buildLabeledTextField(
                "أضف سيرة ذاتية تعرف عن نفسك وتعليمك وخبراتك ومهاراتك",
                "",
                _detailedBioController,
                maxLines: 4),
            _buildDropdownField("المهارات", "اختر مهاراتك وتخصصاتك"),
            _buildLabeledTextField("كلمة المرور الجديدة",
                "ادخل كلمة المرور الخاص بك", _newPasswordController,
                obscureText: true),
            _buildLabeledTextField("تأكيد كلمة المرور",
                "ادخل كلمة المرور الخاص بك", _confirmPasswordController,
                obscureText: true),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // TODO: Handle password change navigation or logic.
                },
                child: const Text("تغير كلمة المرور",
                    style: TextStyle(color: Color(0xFF00C4A1))),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(

              onTap: () {
                // TODO: Handle form submission.
                print("Save button pressed!");
                print("First Name: ${_firstNameController.text}");
              },
              text: 'حفظ',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top section with the profile picture and edit buttons.
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFCEE5E6),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 43.h,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              // --- THIS IS THE UPDATED PART ---
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: const Icon(Icons.edit,
                      color: Styles.PRIMARY_COLOR, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.grey)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLabeledTextField(
              "الاسم", "اكتب اسمك", _firstNameController),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLabeledTextField(
              "الاسم العائلة", "اكتب اسم العائلة", _lastNameController),
        ),
      ],
    );
  }

  /// A reusable helper for a label + your CustomTextField.
  Widget _buildLabeledTextField(
      String label, String hint, TextEditingController controller,
      {int maxLines = 1, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black),
              children: const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          CustomTextField(
            controller: controller,
            hint: hint,
            maxLines: maxLines,
            obscureText: obscureText,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  /// A reusable helper for a styled dropdown-like field.
  Widget _buildDropdownField(String label, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black),
              children: const [
                TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16))
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hintText, style: TextStyle(color: Colors.grey.shade600)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
