import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/on_boarding/model/user_type_route_args.dart';
import 'package:talent_flow/features/setting/model/create_contract_route_args.dart';
import 'package:talent_flow/features/setting/model/user_completion_route_args.dart';

void main() {
  group('route argument compatibility', () {
    test('user type accepts the legacy login flag', () {
      final arguments = UserTypeRouteArgs.fromRoute({
        'from_login': true,
      });

      expect(arguments.fromLogin, isTrue);
    });

    test('user completion accepts the legacy onboarding flag', () {
      final arguments = UserCompletionRouteArgs.fromRoute({
        'fromOnboarding': true,
      });

      expect(arguments.fromOnboarding, isTrue);
    });

    test('contract arguments accept legacy aliases and string ids', () {
      final arguments = CreateContractRouteArgs.fromRoute({
        'project_id': '12',
        'conversation_id': 34,
        'user_id': '56',
        'contract_id': 78,
      });

      expect(arguments.projectId, 12);
      expect(arguments.conversationId, 34);
      expect(arguments.freelancerId, 56);
      expect(arguments.contractId, 78);
    });

    test('typed route arguments pass through unchanged', () {
      const arguments = CreateContractRouteArgs(projectId: 12);

      expect(CreateContractRouteArgs.fromRoute(arguments), same(arguments));
    });
  });
}
