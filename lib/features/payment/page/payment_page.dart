import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import '../../../components/custom_button.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentMethodIndex = 0;

  final List<Map<String, dynamic>> paymentOptions = [
    {'icon': 'assets/images/visa1.png', 'key': 'payment.bank_transfer'},
    {'icon': 'assets/images/visa1.png', 'key': 'payment.bank_account'},
    {'icon': 'assets/images/visa1.png', 'key': 'payment.visa_card'},
    {'icon': 'assets/images/visa1.png', 'key': 'payment.paypal'},
    {'icon': 'assets/images/visa1.png', 'key': 'payment.e_wallet'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          "assets/images/Talent Flow logo 1 1.png",
          height: 35,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'payment.title'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'payment.choose_method'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            ListAnimator(
              data: [
                ...paymentOptions.map(
                      (option) => _buildPaymentOption(
                    text: tr(option['key']),
                    iconPath: option['icon'],
                    index: paymentOptions.indexOf(option),
                  ),
                )
              ],
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'payment.next'.tr(),
              onTap: () {
                print(
                  'Selected payment method: ${tr(paymentOptions[_selectedPaymentMethodIndex]['key'])}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String text,
    required String iconPath,
    required int index,
  }) {
    final bool isSelected = _selectedPaymentMethodIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPaymentMethodIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F9F6) : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected ? const Color(0xFF00C4A1) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Image.asset(iconPath, height: 24, width: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C4A1)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00C4A1),
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
