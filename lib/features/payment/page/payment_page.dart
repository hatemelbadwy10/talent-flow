import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../bloc/payment_bloc.dart';
import '../model/model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentMethodIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentBloc(sl())..add(Add()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:CustomAppBar(title: 'payment.title'.tr()),
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
              Expanded(
                child: BlocBuilder<PaymentBloc, AppState>(
                  builder: (context, state) {
                    if (state is Loading) {
                      // Show shimmer effect
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (state is Done) {
                      final List<PaymentModel> paymentMethods = state.list as List<PaymentModel>;
                      return ListAnimator(
                        data: paymentMethods
                            .map((option) => _buildPaymentOption(
                          text: option.name ?? '',
                          iconPath: option.image ?? 'assets/images/visa1.png',
                          index: paymentMethods.indexOf(option),
                        ))
                            .toList(),
                      );
                    } else if (state is Error) {
                      return Center(
                        child: Text(
                          'payment.error'.tr(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'payment.next'.tr(),
                onTap: () {
                  final bloc = context.read<PaymentBloc>();
                  if (bloc.state is Done) {
                    final paymentMethods = (bloc.state as Done).list;

                  }
                },
              ),
            ],
          ),
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
              Image.network(iconPath, height: 24, width: 24, errorBuilder: (_, __, ___) => const Icon(Icons.payment)),
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
                    color: isSelected ? const Color(0xFF00C4A1) : Colors.grey.shade400,
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
