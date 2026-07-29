import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/setting/bloc/portofilo_form_bloc.dart';

void main() {
  group('PortfolioFormBloc', () {
    test('updates a typed form field', () async {
      final bloc = PortfolioFormBloc();

      bloc.add(
        const UpdateFormField(
          formIndex: 0,
          fieldName: 'title',
          value: 'Mobile application',
        ),
      );
      final state = await bloc.stream.first as PortfolioFormEditing;

      expect(state.data.forms.first.title, 'Mobile application');
      await bloc.close();
    });

    test('only becomes ready when both terms are accepted', () async {
      final bloc = PortfolioFormBloc();

      bloc
        ..add(const SubmitAllPortfolios())
        ..add(const UpdateSingleTerm(termIndex: 1, isAccepted: true))
        ..add(const UpdateSingleTerm(termIndex: 2, isAccepted: true))
        ..add(const SubmitAllPortfolios());

      final states = await bloc.stream.take(4).toList();

      expect(states.first, isA<PortfolioFormEditing>());
      expect(states.last, isA<PortfolioFormReadyForSubmission>());
      await bloc.close();
    });
  });
}
