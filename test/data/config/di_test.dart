import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/data/config/di.dart' as di;
import 'package:talent_flow/features/setting/repo/bank_accounts_repo.dart';
import 'package:talent_flow/features/setting/repo/bank_accounts_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await di.sl.reset();
  });

  test('registers the bank accounts implementation behind its interface',
      () async {
    SharedPreferences.setMockInitialValues({});

    await di.init();

    expect(di.sl.isRegistered<BankAccountsRepository>(), isTrue);
    expect(
      di.sl<BankAccountsRepository>(),
      same(di.sl<BankAccountsRepo>()),
    );
  });
}
