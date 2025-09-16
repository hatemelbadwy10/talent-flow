import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/core/app_event.dart';
import '../../../../components/custom_button.dart';
import '../../../../data/config/di.dart';
import '../../widgets/auth_base.dart';
import 'bloc/confirm_code_bloc.dart';

class ConfirmCodeScreen extends StatefulWidget {
  final Map<String, dynamic> argument;
  const ConfirmCodeScreen({super.key, required this.argument});

  @override
  State<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Widget _buildCodeInput(int index) {
    return SizedBox(
      width: 50,
      height: 64,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
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
              borderSide:
              const BorderSide(color: Colors.blueAccent, width: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInputRow() {
    return Form(
      key: _formKey,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfirmCodeBloc(sl<ConfirmCodeRepo>()),
      child: AuthBase(
        children: [
          SizedBox(height: 86.h),
          Text(
            "confirm_code.title".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 40),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              "confirm_code.enter_code".tr(),
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),

          _buildCodeInputRow(),
          const SizedBox(height: 24),

          // ✅ خلى الزرار ياخد الـ context الصح من تحت BlocProvider
          Builder(
            builder: (context) {
              return CustomButton(
                text: "confirm_code.send".tr(),
                onTap: () {
                  final code = _controllers.map((c) => c.text).join();
                  if (code.length == 6) {
                    final email = widget.argument["email"];
                    final isRegister = widget.argument["isRegister"] ?? false;
                    log('email $email');
                    context.read<ConfirmCodeBloc>().add(
                      Click(arguments: {
                        "identifier": email,
                        "otp": code,
                        "isRegister": isRegister
                      }),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text("confirm_code.error_incomplete".tr())),
                    );
                  }
                },
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF031A1B),
                    Color(0xFF0C7D81),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
