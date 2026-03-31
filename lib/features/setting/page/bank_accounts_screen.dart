import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';

import '../../../app/core/user_completion_guard.dart';
import '../bloc/bank_accounts_bloc.dart';
import '../bloc/bank_accounts_event.dart';
import '../bloc/bank_accounts_state.dart';
import '../model/bank_accounts_request_model.dart';
import '../model/bank_accounts_response_model.dart';
import '../widgets/setting_app_bar.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  late final BankAccountsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BankAccountsBloc(sl())..add(const FetchBankAccounts());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _bloc.add(const FetchBankAccounts(showLoading: false));
  }

  void _openAddEditSheet({
    BankAccountModel? account,
    required List<BankOptionModel> bankOptions,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BankAccountFormBottomSheet(
          account: account,
          bankOptions: bankOptions,
          onSubmit: (request) {
            if (account == null) {
              _bloc.add(AddBankAccount(request: request));
            } else {
              _bloc.add(UpdateBankAccount(request: request));
            }
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BankAccountModel account) async {
    if (account.id == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('bank_accounts_screen.delete_confirmation_title'.tr()),
          content: Text(
            'bank_accounts_screen.delete_confirmation_message'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('bank_accounts_screen.cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'bank_accounts_screen.confirm_delete'.tr(),
                style: const TextStyle(color: Color(0xFFDB5353)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _bloc.add(DeleteBankAccount(id: account.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<BankAccountsBloc, BankAccountsState>(
        listener: (context, state) {
          UserCompletionGuard.updateStoredFlags(
            hasBankAccount: state.accounts.isNotEmpty,
          );
          final messenger = ScaffoldMessenger.of(context);
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            appBar: CustomAppBar(
              title: 'settings_screen.bank_accounts'.tr(),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: IconButton(
                    onPressed: () => _openAddEditSheet(
                      bankOptions: state.bankOptions,
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Styles.PRIMARY_COLOR,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: state.isLoading && state.accounts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.accounts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Text(
                                    'bank_accounts_screen.empty'.tr(),
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            children: [
                              _BankAccountsTable(
                                accounts: state.accounts,
                                onEdit: (account) => _openAddEditSheet(
                                  account: account,
                                  bankOptions: state.bankOptions,
                                ),
                                onDelete: _confirmDelete,
                              ),
                            ],
                          ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BankAccountsTable extends StatelessWidget {
  const _BankAccountsTable({
    required this.accounts,
    required this.onEdit,
    required this.onDelete,
  });

  final List<BankAccountModel> accounts;
  final ValueChanged<BankAccountModel> onEdit;
  final ValueChanged<BankAccountModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, 760.0);
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
                  const _BankAccountsTableHeader(),
                  ListView.separated(
                    itemCount: accounts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return _BankAccountsTableRow(
                        account: account,
                        onEdit: () => onEdit(account),
                        onDelete: () => onDelete(account),
                      );
                    },
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

class _BankAccountsTableHeader extends StatelessWidget {
  const _BankAccountsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: const Color(0xFFF7F8FA),
      child: const Row(
        children: [
          _TableCell(
            width: 210,
            text: 'bank_accounts_screen.account_name',
            isHeader: true,
          ),
          _TableCell(
            width: 210,
            text: 'bank_accounts_screen.account_number',
            isHeader: true,
          ),
          _TableCell(
            width: 170,
            text: 'bank_accounts_screen.bank_name',
            isHeader: true,
          ),
          _TableCell(
            width: 140,
            text: '',
            isHeader: true,
          ),
        ],
      ),
    );
  }
}

class _BankAccountsTableRow extends StatelessWidget {
  const _BankAccountsTableRow({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final BankAccountModel account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        children: [
          _TableCell(
            width: 210,
            valueWidget: Text(
              account.name ?? account.ownerName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _TableCell(
            width: 210,
            valueWidget: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                account.number ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          _TableCell(
            width: 170,
            valueWidget: Text(
              account.bankName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _TableCell(
            width: 140,
            valueWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: const Color(0xFFFF3B30),
                  onTap: onDelete,
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF6B7280),
                  onTap: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.width,
    this.text,
    this.isHeader = false,
    this.valueWidget,
  });

  final double width;
  final String? text;
  final bool isHeader;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: valueWidget ??
          Text(
            (text ?? '').isEmpty ? '' : text!.tr(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF414141),
              fontSize: isHeader ? 20 : 16,
              fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _BankAccountFormBottomSheet extends StatefulWidget {
  const _BankAccountFormBottomSheet({
    this.account,
    required this.bankOptions,
    required this.onSubmit,
  });

  final BankAccountModel? account;
  final List<BankOptionModel> bankOptions;
  final ValueChanged<BankAccountUpsertRequestModel> onSubmit;

  @override
  State<_BankAccountFormBottomSheet> createState() =>
      _BankAccountFormBottomSheetState();
}

class _BankAccountFormBottomSheetState
    extends State<_BankAccountFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  int? _selectedBankId;

  bool get _isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _numberController =
        TextEditingController(text: widget.account?.number ?? '');
    _selectedBankId = widget.account?.bankId;
    final containsSelectedBank = widget.bankOptions.any(
      (bank) => bank.id == _selectedBankId,
    );
    if (!containsSelectedBank) {
      _selectedBankId = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }
    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('bank_accounts_screen.validation_bank'.tr()),
        ),
      );
      return;
    }

    widget.onSubmit(
      BankAccountUpsertRequestModel(
        id: widget.account?.id,
        name: _nameController.text.trim(),
        number: _numberController.text.trim(),
        bankId: _selectedBankId!,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEdit
                  ? 'bank_accounts_screen.edit_account'.tr()
                  : 'bank_accounts_screen.add_account'.tr(),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'bank_accounts_screen.account_name'.tr(),
                hintText: 'bank_accounts_screen.account_name_hint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'bank_accounts_screen.validation_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'bank_accounts_screen.account_number'.tr(),
                hintText: 'bank_accounts_screen.account_number_hint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'bank_accounts_screen.validation_number'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selectedBankId,
              items: widget.bankOptions
                  .map(
                    (bank) => DropdownMenuItem<int>(
                      value: bank.id,
                      child: Text(bank.name),
                    ),
                  )
                  .toList(),
              onChanged: widget.bankOptions.isEmpty
                  ? null
                  : (value) {
                      setState(() => _selectedBankId = value);
                    },
              decoration: InputDecoration(
                labelText: 'bank_accounts_screen.bank_name'.tr(),
                hintText: widget.bankOptions.isEmpty
                    ? 'bank_accounts_screen.no_banks'.tr()
                    : 'bank_accounts_screen.bank_placeholder'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEdit
                      ? 'bank_accounts_screen.update'.tr()
                      : 'bank_accounts_screen.save'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
