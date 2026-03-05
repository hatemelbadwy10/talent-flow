import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'package:talent_flow/components/animated_widget.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';
import 'package:talent_flow/features/setting/bloc/contracts_bloc.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';
import 'package:talent_flow/features/setting/widgets/contract_list_item.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContractsBloc(sl())..add(Add()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'settings_screen.contracts'.tr(),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                CustomNavigator.push(Routes.createContract);
              },
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.black87,
            ),
          ],
        ),
        body: BlocBuilder<ContractsBloc, AppState>(
          builder: (context, state) {
            if (state is Loading) {
              return const ProjectCardShimmer();
            }

            if (state is Error) {
              return Center(
                child: Text('something_went_wrong'.tr()),
              );
            }

            if (state is Done) {
              final contracts = state.list?.cast<ContractModel>() ?? [];
              if (contracts.isEmpty) {
                return const Center(child: Text('No contracts found'));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListAnimator(
                  addPadding: false,
                  customPadding: EdgeInsets.zero,
                  data: contracts
                      .map(
                        (contract) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ContractListItem(
                            contract: contract,
                            onTap: () {
                              final id = contract.id;
                              if (id == null) {
                                return;
                              }
                              CustomNavigator.push(
                                Routes.contractDetails,
                                arguments: id,
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
