import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;


abstract class ProviderList {
  static List<BlocProvider> providers = [
    // BlocProvider<LanguageBloc>(create: (_) => di.sl<LanguageBloc>()..add(Init())),
    // BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),
    // BlocProvider<UserBloc>(create: (_) => di.sl<UserBloc>()),
    // BlocProvider<BannersBloc>(create: (_) => di.sl<BannersBloc>()),
    // BlocProvider<MembershipInstructionsBloc>(create: (_) => di.sl<MembershipInstructionsBloc>()),
    //
    // ///Log out
    // BlocProvider<LogoutBloc>(create: (_) => di.sl<LogoutBloc>()),
  ];
}
