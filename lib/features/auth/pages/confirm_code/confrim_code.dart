import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/core/app_event.dart';
import '../../../../app/core/styles.dart';
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

  // Enhanced paste handling method
  void _handlePaste(String pastedText, int currentIndex) {
    // Clean the pasted text - remove any non-digit characters
    final cleanText = pastedText.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) return;

    // Clear all controllers first
    for (var controller in _controllers) {
      controller.clear();
    }

    // Fill controllers with pasted digits
    final chars = cleanText.split('');
    for (int i = 0; i < _controllers.length && i < chars.length; i++) {
      _controllers[i].text = chars[i];
    }

    // Focus on the last filled field or the last field if all are filled
    final lastIndex = (chars.length - 1).clamp(0, _controllers.length - 1);
    _focusNodes[lastIndex].requestFocus();
  }

  Widget _buildCodeInput(int index) {
    return SizedBox(
      width: 50,
      height: 64,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            // Handle backspace
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              _onBackspace(index);
            }
            // Handle paste with Ctrl+V
            else if (event.isControlPressed &&
                event.logicalKey == LogicalKeyboardKey.keyV) {
              Clipboard.getData(Clipboard.kTextPlain).then((data) {
                if (data?.text != null) {
                  _handlePaste(data!.text!, index);
                }
              });
            }
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
          onChanged: (value) {
            if (value.length > 1) {
              // Handle paste operation
              _handlePaste(value, index);
            } else {
              // Normal single character input
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildCodeInputRow(BuildContext context) {
    final isArabic = context.locale.languageCode == "ar";

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Add a paste button for better UX
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _handlePaste(data!.text!, 0);
                  }
                },
                icon: const Icon(Icons.paste, size: 16),
                label:  Text(
                  "paste".tr(),
                  style: TextStyle(fontSize: 12,
                  color: Styles.PRIMARY_COLOR
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: isArabic
                ? [
              _buildCodeInput(5),
              _buildCodeInput(4),
              _buildCodeInput(3),
              const Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
              _buildCodeInput(2),
              _buildCodeInput(1),
              _buildCodeInput(0),
            ]
                : [
              _buildCodeInput(0),
              _buildCodeInput(1),
              _buildCodeInput(2),
              const Text('-', style: TextStyle(fontSize: 24, color: Colors.grey)),
              _buildCodeInput(3),
              _buildCodeInput(4),
              _buildCodeInput(5),
            ],
          ),
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

          _buildCodeInputRow(context),
          const SizedBox(height: 24),

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
                        "isRegister": isRegister,
                        "isFromLogin": widget.argument["isFromLogin"],
                      }),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("confirm_code.error_incomplete".tr())),
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