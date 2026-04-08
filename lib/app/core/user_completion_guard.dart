import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/user_completion_dialog.dart';
import '../../data/config/di.dart';
import '../../features/setting/repo/bank_accounts_repo.dart';
import '../../main_blocs/user_bloc.dart';
import '../../navigation/custom_navigation.dart';
import '../../navigation/routes.dart';
import 'app_event.dart';
import 'app_storage_keys.dart';

enum GuardedAction {
  addProject,
  addOffer,
}

enum MissingRequirement {
  addedWorks,
  bankAccount,
  identityVerification,
}

class UserCompletionStatus {
  const UserCompletionStatus({
    required this.isFreelancer,
    required this.addedWorks,
    required this.hasBankAccount,
    required this.identityAuthenticated,
  });

  final bool isFreelancer;
  final bool addedWorks;
  final bool hasBankAccount;
  final bool identityAuthenticated;

  List<MissingRequirement> get missingRequirements {
    final requirements = <MissingRequirement>[];
    if (isFreelancer && !addedWorks) {
      requirements.add(MissingRequirement.addedWorks);
    }
    if (!isFreelancer && !hasBankAccount) {
      requirements.add(MissingRequirement.bankAccount);
    }
    if (!identityAuthenticated) {
      requirements.add(MissingRequirement.identityVerification);
    }
    return requirements;
  }

  bool get canAddOffer => isFreelancer && addedWorks && identityAuthenticated;

  bool get canAddProject =>
      !isFreelancer && hasBankAccount && identityAuthenticated;

  UserCompletionStatus copyWith({
    bool? isFreelancer,
    bool? addedWorks,
    bool? hasBankAccount,
    bool? identityAuthenticated,
  }) {
    return UserCompletionStatus(
      isFreelancer: isFreelancer ?? this.isFreelancer,
      addedWorks: addedWorks ?? this.addedWorks,
      hasBankAccount: hasBankAccount ?? this.hasBankAccount,
      identityAuthenticated:
          identityAuthenticated ?? this.identityAuthenticated,
    );
  }
}

abstract class UserCompletionGuard {
  static SharedPreferences get _prefs => sl<SharedPreferences>();

  static UserCompletionStatus get status {
    final rawUser = _readUserData();
    final storedRole = _prefs.getBool(AppStorageKey.isFreelancer) ?? true;

    return UserCompletionStatus(
      isFreelancer: _resolveIsFreelancer(rawUser, storedRole),
      addedWorks: _toBool(rawUser['added_works']),
      hasBankAccount: _toBool(rawUser['has_bank_account']),
      identityAuthenticated: _toBool(rawUser['identity_authenticated']),
    );
  }

  static Future<void> updateStoredFlags({
    bool? addedWorks,
    bool? hasBankAccount,
    bool? identityAuthenticated,
    String? identityVerifyStatus,
  }) async {
    final rawUser = _readUserData();
    if (rawUser.isEmpty) return;

    if (addedWorks != null) {
      rawUser['added_works'] = addedWorks;
    }
    if (hasBankAccount != null) {
      rawUser['has_bank_account'] = hasBankAccount;
    }
    if (identityAuthenticated != null) {
      rawUser['identity_authenticated'] = identityAuthenticated;
    }
    if (identityVerifyStatus != null) {
      rawUser['identity_verify_status'] = identityVerifyStatus;
    }

    await _prefs.setString(AppStorageKey.userData, jsonEncode(rawUser));
    UserBloc.instance.add(Click());
  }

  static String? get identityVerifyStatus {
    return _readUserData()['identity_verify_status']?.toString();
  }

  static Future<void> handlePostAuthNavigation() async {
    final currentStatus = status;

    if (currentStatus.isFreelancer) {
      if (!currentStatus.addedWorks) {
        CustomNavigator.push(
          Routes.addYourProject,
          clean: true,
          arguments: {'fromOnboarding': true},
        );
        return;
      }

      if (!currentStatus.identityAuthenticated) {
        CustomNavigator.push(
          Routes.identityVerification,
          clean: true,
          arguments: {'fromOnboarding': true},
        );
        return;
      }
    }

    CustomNavigator.push(Routes.navBar, clean: true);
  }

  static Future<bool> ensureCanAddOffer(BuildContext context) async {
    final currentStatus = status;
    if (!currentStatus.isFreelancer || currentStatus.canAddOffer) {
      return true;
    }

    await _showCompletionDialog(
      context,
      currentStatus,
      action: GuardedAction.addOffer,
    );
    return false;
  }

  static Future<bool> ensureCanAddProject(BuildContext context) async {
    final currentStatus = await _resolveProjectStatus();
    if (!context.mounted) {
      return false;
    }
    if (currentStatus.isFreelancer || currentStatus.canAddProject) {
      return true;
    }

    await _showCompletionDialog(
      context,
      currentStatus,
      action: GuardedAction.addProject,
    );
    return false;
  }

  static Future<void> _showCompletionDialog(
    BuildContext context,
    UserCompletionStatus currentStatus, {
    required GuardedAction action,
  }) async {
    final primaryRequirement = currentStatus.missingRequirements.first;
    final primaryRoute = switch (primaryRequirement) {
      MissingRequirement.addedWorks => Routes.addYourProject,
      MissingRequirement.bankAccount => Routes.bankAccounts,
      MissingRequirement.identityVerification => Routes.identityVerification,
    };
    final primaryLabelKey = switch (primaryRequirement) {
      MissingRequirement.addedWorks => 'user_completion.go_to_work',
      MissingRequirement.bankAccount => 'user_completion.go_to_bank_account',
      MissingRequirement.identityVerification =>
        'user_completion.go_to_identity',
    };
    final primaryArguments = {
      'fromOnboarding': false,
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return UserCompletionDialog(
          action: action,
          missingRequirements: currentStatus.missingRequirements,
          primaryLabelKey: primaryLabelKey,
          onPrimaryTap: () {
            Navigator.of(dialogContext).pop();
            CustomNavigator.push(
              primaryRoute,
              arguments: primaryArguments,
            );
          },
        );
      },
    );
  }

  static Future<UserCompletionStatus> _resolveProjectStatus() async {
    final currentStatus = status;
    if (currentStatus.isFreelancer) {
      return currentStatus;
    }

    final result = await sl<BankAccountsRepo>().getBankAccounts();
    return result.fold(
      (_) => currentStatus,
      (response) => currentStatus.copyWith(
        hasBankAccount: response.items.isNotEmpty,
      ),
    );
  }

  static Map<String, dynamic> _readUserData() {
    final encoded = _prefs.getString(AppStorageKey.userData);
    if (encoded == null || encoded.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  static bool _resolveIsFreelancer(
    Map<String, dynamic> rawUser,
    bool storedRole,
  ) {
    final type = rawUser['user_type']?.toString().toLowerCase();
    if (type == 'freelancer') {
      return true;
    }
    if (type == 'entrepreneur') {
      return false;
    }
    return storedRole;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
}
