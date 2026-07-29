import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/projects/widgets/projects_shimmer.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_bloc.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_event.dart';
import 'package:talent_flow/features/setting/bloc/contract_details_state.dart';
import 'package:talent_flow/features/setting/repo/contracts_repository.dart';
import 'package:talent_flow/features/setting/widgets/contract_details/contract_details_body.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';

class ContractDetailsScreen extends StatefulWidget {
  const ContractDetailsScreen({
    super.key,
    required this.contractId,
    required this.repository,
    required this.isFreelancer,
  });

  final int contractId;
  final ContractsRepository repository;
  final bool isFreelancer;

  @override
  State<ContractDetailsScreen> createState() => _ContractDetailsScreenState();
}

class _ContractDetailsScreenState extends State<ContractDetailsScreen> {
  bool _shouldRefreshOnPop = false;

  void _markUpdated() {
    _shouldRefreshOnPop = true;
  }

  Future<bool> _handleWillPop() async {
    Navigator.of(context).pop(_shouldRefreshOnPop);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleWillPop();
      },
      child: BlocProvider(
        create: (_) => ContractDetailsBloc(repository: widget.repository)
          ..add(ContractDetailsRequested(widget.contractId)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: CustomAppBar(
            title: 'contract_details_screen.title'.tr(),
            centerTitle: true,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(_shouldRefreshOnPop),
          ),
          body: BlocBuilder<ContractDetailsBloc, ContractDetailsState>(
            builder: (context, state) {
              if (state is ContractDetailsLoading) {
                return const ProjectCardShimmer();
              }

              if (state is ContractDetailsFailed) {
                return Center(child: Text('something_went_wrong'.tr()));
              }

              if (state is ContractDetailsLoaded) {
                final contract = state.contract;
                return ContractDetailsBody(
                  contract: contract,
                  onContractUpdated: _markUpdated,
                  repository: widget.repository,
                  isFreelancer: widget.isFreelancer,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
