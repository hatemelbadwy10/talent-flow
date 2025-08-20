import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../components/custom_button.dart';
// We are replacing CustomTextField with this new UI, so it might not be needed.
// import '../../../components/custom_text_form_field.dart';
import '../../../navigation/routes.dart';
import '../widgets/auth_base.dart';

// 1. Converted to a StatefulWidget to manage controllers and focus
class ConfirmCodeScreen extends StatefulWidget {
  const ConfirmCodeScreen({super.key});

  @override
  State<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  // 2. Create controllers and focus nodes for each of the 6 input fields
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Add listeners to move focus automatically when a character is entered
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    // 3. Clean up controllers and focus nodes to avoid memory leaks
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Function to handle backspace to move to the previous field
  void _onBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  // Helper method to build a single OTP input box
  Widget _buildCodeInput(int index) {
    return SizedBox(
      width: 50,
      height: 64,
      child: RawKeyboardListener(
        // Use RawKeyboardListener to detect backspace on an empty field
        focusNode: FocusNode(), // Dummy focus node
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(index);
          }
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build the entire row of OTP inputs
  Widget _buildCodeInputRow() {
    return Form(
      key: _formKey,
      child: Directionality(
        // Set Directionality to LTR for the input row itself
        // to ensure numbers are entered in the correct order.
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCodeInput(0),
            _buildCodeInput(1),
            _buildCodeInput(2),
            const Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
            _buildCodeInput(3),
            _buildCodeInput(4),
            _buildCodeInput(5),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AuthBase(
        children: [
          SizedBox(height: 86.h),
          const Text(
            "كود تأكيد الحساب",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),

          // 4. Add the label for the input fields
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              "ادخل الكود",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),

          // 5. Call the method to build the OTP input row
          _buildCodeInputRow(),

          const SizedBox(height: 24),
          CustomButton(
            text: "إرسال",
            onTap: () {
              // 6. Updated logic to validate the code from all 6 boxes
              final code = _controllers.map((c) => c.text).join();
              if (code.length == 6) {
                // Code is complete, proceed with submission
                print("Entered code: $code");
                CustomNavigator.push(Routes.forgetPassword);
              } else {
                // Show an error if the code is incomplete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الكود يجب أن يكون 6 أرقام')),
                );
              }
            },
            gradient: const LinearGradient(
              colors: [
                Color(0xFF031A1B), // Right
                Color(0xFF0C7D81), // Left
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}