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

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  late final ContractsBloc _contractsBloc;

  @override
  void initState() {
    super.initState();
    _contractsBloc = ContractsBloc(sl())..add(Add());
  }

  @override
  void dispose() {
    _contractsBloc.close();
    super.dispose();
  }

  Future<void> _refreshContracts() async {
    _contractsBloc.add(Add());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _contractsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'settings_screen.contracts'.tr(),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     onPressed: () async {
          //       final result =
          //           await CustomNavigator.push(Routes.createContract);
          //       if (!mounted || result != true) {
          //         return;
          //       }
          //       await _refreshContracts();
          //     },
          //     icon: const Icon(Icons.add_circle_outline),
          //     color: Colors.black87,
          //   ),
          // ],
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
                return RefreshIndicator(
                  onRefresh: _refreshContracts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Center(child: Text('No contracts found')),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshContracts,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ListAnimator(
                        addPadding: false,
                        customPadding: EdgeInsets.zero,
                        data: contracts
                            .map(
                              (contract) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ContractListItem(
                                  contract: contract,
                                  onTap: () async {
                                    final id = contract.id;
                                    if (id == null) {
                                      return;
                                    }
                                    final result = await CustomNavigator.push(
                                      Routes.contractDetails,
                                      arguments: id,
                                    );
                                    if (!mounted || result != true) {
                                      return;
                                    }
                                    await _refreshContracts();
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
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
