import 'package:flutter/material.dart';
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
    {
      'icon': 'assets/icons/wallet.png',
      'text': 'الدفع عن طريق الحوالة المالية'
    },
    {'icon': 'assets/images/visa1.png', 'text': 'الدفع عن طريق الحساب البنكي'},
    {'icon': 'assets/images/visa.png', 'text': 'الدفع عن طريق الفيزا كارت'},
    {'icon': 'assets/images/visa.png', 'text': 'الدفع عن طريق الباي بال'},
    {
      'icon': 'assets/images/visa1.png',
      'text': 'الدفع عبر المحفظة الالكترونية'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  'الدفع',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر طريقة الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              ListAnimator(data: [
                ...paymentOptions.map((option) => _buildPaymentOption(
                    text: option['text'],
                    iconPath: option['icon'],
                    index: paymentOptions.indexOf(option)))
              ]),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'التالي',
                onTap: () {
                  print(
                      'Selected payment method: ${paymentOptions[_selectedPaymentMethodIndex]['text']}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String text, required String iconPath, required int index}) {
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
              color:
                  isSelected ? const Color(0xFF00C4A1) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Image.asset("assets/images/visa.png", height: 24, width: 24),
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
                // The inner dot appears only when the item is selected.
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
