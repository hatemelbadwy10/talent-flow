import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';
import '../../../data/config/di.dart';
import '../../../navigation/custom_navigation.dart';
import '../../../navigation/routes.dart';
import '../bloc/account_statement_bloc.dart';
import '../model/account_statement_response_model.dart';
import '../widgets/setting_app_bar.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final AccountStatementBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AccountStatementBloc(sl())..add(Add());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _loadStatements() {
    _bloc.add(
      Add(
        arguments: {
          'search': _searchController.text.trim(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: CustomAppBar(
          title: 'settings_screen.account_statement'.tr(),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SearchSection(
                controller: _searchController,
                onSearch: _loadStatements,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<AccountStatementBloc, AppState>(
                  builder: (context, state) {
                    if (state is Loading) {
                      return const _TableLoading();
                    }

                    if (state is Error) {
                      return Center(
                        child: Text('something_went_wrong'.tr()),
                      );
                    }

                    if (state is Done) {
                      final statements =
                          state.list?.cast<AccountStatementItemModel>() ?? [];
                      if (statements.isEmpty) {
                        return Center(
                          child: Text('account_statement_screen.empty'.tr()),
                        );
                      }
                      return _AccountStatementTable(statements: statements);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'account_statement_screen.search_hint'.tr(),
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                onPressed: onSearch,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0C7D81)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountStatementTable extends StatelessWidget {
  const _AccountStatementTable({required this.statements});

  final List<AccountStatementItemModel> statements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, 860.0);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  const _TableHeader(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: statements.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF0F1F3)),
                      itemBuilder: (context, index) {
                        final statement = statements[index];
                        return _TableRowItem(statement: statement);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: const Color(0xFFF7F8FA),
      child: Row(
        children: [
          _TableTextCell(
            text: 'account_statement_screen.details'.tr(),
            width: 70,
            isHeader: true,
          ),
          _TableTextCell(
            text: 'account_statement_screen.project_name'.tr(),
            width: 190,
            isHeader: true,
          ),
          _TableTextCell(
            text: 'account_statement_screen.service_provider'.tr(),
            width: 170,
            isHeader: true,
          ),
          _TableTextCell(
            text: 'account_statement_screen.date'.tr(),
            width: 130,
            isHeader: true,
          ),
          _TableTextCell(
            text: 'account_statement_screen.project_cost'.tr(),
            width: 145,
            isHeader: true,
          ),
          _TableTextCell(
            text: 'account_statement_screen.commission_paid'.tr(),
            width: 155,
            isHeader: true,
          ),
        ],
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  const _TableRowItem({required this.statement});

  final AccountStatementItemModel statement;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Center(
              child: IconButton(
                onPressed: statement.id == null
                    ? null
                    : () {
                        CustomNavigator.push(
                          Routes.accountStatementDetails,
                          arguments: statement.id,
                        );
                      },
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 20,
                ),
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          _TableTextCell(text: statement.projectName ?? '-', width: 190),
          _TableTextCell(
              text: statement.serviceProviderName ?? '-', width: 170),
          _TableTextCell(text: statement.date ?? '-', width: 130),
          _TableTextCell(text: statement.projectCost ?? '-', width: 145),
          _TableTextCell(text: statement.commissionPaid ?? '-', width: 155),
        ],
      ),
    );
  }
}

class _TableTextCell extends StatelessWidget {
  const _TableTextCell({
    required this.text,
    required this.width,
    this.isHeader = false,
  });

  final String text;
  final double width;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 12 : 13,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
          color: isHeader ? const Color(0xFF6B7280) : const Color(0xFF1F2937),
        ),
      ),
    );
  }
}

class _TableLoading extends StatelessWidget {
  const _TableLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) {
          return Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}
