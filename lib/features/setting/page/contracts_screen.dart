import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';
import 'package:talent_flow/features/setting/bloc/contracts_bloc.dart';
import 'package:talent_flow/features/setting/bloc/contracts_event.dart';
import 'package:talent_flow/features/setting/bloc/contracts_state.dart';
import 'package:talent_flow/features/setting/repo/contracts_repository.dart';
import 'package:talent_flow/features/setting/widgets/contract_list_item.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class ContractsScreen extends StatefulWidget {
  final ContractsReadRepository repository;

  const ContractsScreen({super.key, required this.repository});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  late final ContractsBloc _contractsBloc;

  @override
  void initState() {
    super.initState();
    _contractsBloc = ContractsBloc(repository: widget.repository)
      ..add(const ContractsRequested());
  }

  @override
  void dispose() {
    _contractsBloc.close();
    super.dispose();
  }

  Future<void> _refreshContracts() async {
    _contractsBloc.add(const ContractsRequested());
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
        ),
        body: BlocBuilder<ContractsBloc, ContractsState>(
          builder: (context, state) {
            if (state is ContractsLoading) {
              return const ProjectCardShimmer();
            }

            if (state is ContractsFailed) {
              return Center(
                child: Text('something_went_wrong'.tr()),
              );
            }

            if (state is ContractsLoaded) {
              final contracts = state.contracts;
              if (contracts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshContracts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 180),
                      Center(child: Text('no_contracts_found'.tr())),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshContracts,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: contracts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contract = contracts[index];
                    return ContractListItem(
                      contract: contract,
                      repository: widget.repository,
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
                    );
                  },
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
