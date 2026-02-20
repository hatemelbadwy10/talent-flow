import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/features/setting/widgets/contract_list_item.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CustomAppBar(
        title: 'settings_screen.contracts'.tr(),
        
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ListAnimator(
          addPadding: false,
          customPadding: EdgeInsets.zero,
          data: [
            ContractListItem(
              status: ContractStatus.pending,
              titleKey: 'contracts_screen.contract_title',
              sizeKey: 'contracts_screen.contract_size',
            ),
            SizedBox(height: 12),
            ContractListItem(
              status: ContractStatus.rejected,
              titleKey: 'contracts_screen.contract_title',
              sizeKey: 'contracts_screen.contract_size',
            ),
            SizedBox(height: 12),
            ContractListItem(
              status: ContractStatus.approved,
              titleKey: 'contracts_screen.contract_title',
              sizeKey: 'contracts_screen.contract_size',
            ),
          ],
        ),
      ),
    );
  }
}
