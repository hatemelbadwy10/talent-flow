import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart' hide Notification;
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/auth/pages/register/register.dart';
import 'package:talent_flow/features/auth/models/auth_route_args.dart';
import 'package:talent_flow/features/auth/pages/login/repo/login_repo.dart';
import 'package:talent_flow/features/auth/pages/register/repo/register_repo.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/social_media_repo.dart';
import 'package:talent_flow/features/auth/pages/change_password/repo/change_password_repo.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';
import 'package:talent_flow/features/auth/pages/send_verification/send_verification_repo/send_verification_repo.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/chat_repo.dart';
import 'package:talent_flow/data/realtime/pusher_service.dart';
import 'package:talent_flow/features/home/bloc/freelancer_chat_bloc.dart';
import 'package:talent_flow/features/home/repo/home_repo.dart';
import 'package:talent_flow/features/new_projects/page/add_project.dart';
import 'package:talent_flow/features/payment/model/contract_payment_args.dart';
import 'package:talent_flow/features/payment/page/contract_payment_confirm_screen.dart';
import 'package:talent_flow/features/payment/page/contract_payment_request_screen.dart';
import 'package:talent_flow/features/payment/page/payment_page.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';
import 'package:talent_flow/features/projects/page/single_project_view.dart';
import 'package:talent_flow/features/projects/model/project_route_args.dart';
import 'package:talent_flow/features/setting/bloc/notification_bloc.dart';
import 'package:talent_flow/features/setting/bloc/chats_bloc.dart';
import 'package:talent_flow/features/setting/repo/chats_repo.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';
import 'package:talent_flow/features/setting/repo/bank_accounts_repo.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';
import 'package:talent_flow/features/setting/repo/acceptance_test_repository.dart';
import 'package:talent_flow/features/setting/page/add_projects.dart';
import 'package:talent_flow/features/setting/model/create_contract_route_args.dart';
import 'package:talent_flow/features/setting/page/add_single_work_screen.dart';
import 'package:talent_flow/features/setting/page/favourite.dart';
import 'package:talent_flow/features/setting/page/notification.dart';
import 'package:talent_flow/features/setting/page/dashboard_screen.dart';
import '../app/core/app_storage_keys.dart';
import '../data/config/di.dart';
import '../features/auth/pages/change_password/change_password.dart';
import '../features/auth/pages/confirm_code/confrim_code.dart';
import '../features/auth/pages/login/login.dart';
import '../features/auth/pages/send_verification/send_verification.dart';
import '../features/home/page/all_categories.dart';
import '../features/home/page/all_freelancers_view.dart';
import '../features/home/page/entrepreneur_profile.dart';
import '../features/home/page/freelancer_chat_screen.dart';
import '../features/home/page/freelancer_profile.dart';
import '../features/home/page/home_view.dart';
import '../features/home/page/my_freelancer_profile.dart';
import '../features/home/page/partner_profile.dart';
import '../features/home/page/work_screen.dart';
import '../features/home/model/freelancer_profile_model.dart';
import '../features/home/model/home_route_args.dart';
import '../features/home/model/partner_model.dart';
import '../features/home/model/work_details_model.dart';
import '../features/nav_bar/page/nav_bar.dart';
import '../features/new_projects/bloc/new_projects_bloc.dart';
import '../features/new_projects/page/add_offer_screen.dart';
import '../features/new_projects/repo/new_projects_repo.dart';
import '../features/new_projects/repo/add_project_repo.dart';
import '../features/new_projects/repo/selection_option_repo.dart';
import '../features/setting/repo/notification_repo.dart';
import '../features/setting/repo/about_repo.dart';
import '../features/setting/repo/account_statement_repo.dart';
import '../features/setting/repo/terms_condation_repo.dart';
import '../features/setting/repo/contracts_repo.dart';
import '../features/setting/repo/dashboard_repo.dart';
import '../features/setting/repo/settings_repo.dart';
import '../features/setting/repo/update_profile_repo.dart';
import '../features/auth/data/auth_session_store.dart';
import '../features/splash/repo/splash_repo.dart';
import '../main_repos/location_options_repo.dart';
import '../features/on_boarding/page/free_lancer_screen.dart';
import '../features/on_boarding/page/on_boarding_screen.dart';
import '../features/on_boarding/model/user_type_route_args.dart';
import '../features/projects/page/my_projects.dart';
import '../features/projects/repo/projects_repo.dart';
import '../features/setting/page/about_talent_flow.dart';
import '../features/setting/page/account_statement_details_screen.dart';
import '../features/setting/page/account_statement_screen.dart';
import '../features/setting/page/acceptance_test_questions_screen.dart';
import '../features/setting/page/bank_accounts_screen.dart';
import '../features/setting/page/chat_screen.dart';
import '../features/setting/page/contract_details_screen.dart';
import '../features/setting/page/contracts_screen.dart';
import '../features/setting/page/create_contract_screen.dart';
import '../features/setting/page/edit_profile.dart';
import '../features/setting/page/edit_work_screen.dart';
import '../features/setting/page/identity_verification_screen.dart';
import '../features/setting/model/user_completion_route_args.dart';
import '../features/setting/page/terms_and_condations.dart';
import '../features/splash/page/splash.dart';
import '../main.dart';
import 'routes.dart';

abstract class CustomNavigator {
  static final GlobalKey<NavigatorState> navigatorState =
      GlobalKey<NavigatorState>();
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldState =
      GlobalKey<ScaffoldMessengerState>();

  static Route<dynamic> onCreateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.app:
        return _pageRoute(const MyApp());
      case Routes.onBoarding:
        return _pageRoute(const OnboardingScreen());
      case Routes.freeLancer:
        return _pageRoute(UserTypeSelectionScreen(
          arguments: UserTypeRouteArgs.fromRoute(settings.arguments),
          sharedPreferences: sl<SharedPreferences>(),
        ));
      case Routes.navBar:
        return _pageRoute(_navBar());
      case Routes.home:
        return _pageRoute(_homeView());
      case Routes.splash:
        return _pageRoute(Splash(repository: sl<SplashRepo>()));
      case Routes.login:
        return _pageRoute(_login());
      case Routes.register:
        return _pageRoute(
          Register(
            repository: sl<RegisterRepo>(),
            socialMediaRepository: sl<SocialMediaRepo>(),
            sessionStore: sl<AuthSessionStore>(),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        );
      case Routes.forgetPassword:
        return _pageRoute(ChangePasswordScreen(
          arguments: ChangePasswordArgs.fromRoute(settings.arguments),
          repository: sl<ChangePasswordRepo>(),
        ));

      case Routes.verificationScreen:
        return _pageRoute(
          SendVerificationScreen(repository: sl<SendVerificationRepo>()),
        );
      case Routes.singleProjectDetails:
        return _pageRoute(SingleProjectView(
          arguments: ProjectDetailsRouteArgs.fromRoute(settings.arguments),
          projectRepository: sl<ProjectsRepo>(),
          chatRepository: sl<ChatRepo>(),
          currentUserId: int.tryParse(
            sl<SharedPreferences>().getString(AppStorageKey.userId) ?? '',
          ),
          isFreelancer:
              sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                  false,
        ));
      case Routes.payment:
        return _pageRoute(PaymentPage(repository: sl<PaymentRepo>()));
      case Routes.about:
        return _pageRoute(
          AboutTalentFlowView(repository: sl<AboutRepo>()),
        );
      case Routes.favorites:
        return _pageRoute(
          Favourite(
            repository: sl<FavouriteRepo>(),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        );
      case Routes.sendCodeScreen:
        return _pageRoute(ConfirmCodeScreen(
          argument: ConfirmCodeArgs.fromRoute(settings.arguments),
          repository: sl<ConfirmCodeRepo>(),
          sessionStore: sl<AuthSessionStore>(),
        ));
      case Routes.allCategories:
        return _pageRoute(
          ServiceCategoryView(
            repository: sl<HomeRepo>(),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        );
      case Routes.addOffer:
        return _pageRoute(BlocProvider(
          create: (context) => NewProjectsBloc(
            repository: sl<NewProjectsRepo>(),
          ),
          child: AddOfferScreen(
            argument: OfferRouteArgs.fromRoute(settings.arguments),
            projectRepository: sl<ProjectsRepo>(),
            currentUserId: int.tryParse(
              sl<SharedPreferences>().getString(AppStorageKey.userId) ?? '',
            ),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    true,
          ),
        ));
      case Routes.addProject:
        return _pageRoute(const AddProject());
      case Routes.addYourProject:
        final arguments = UserCompletionRouteArgs.fromRoute(settings.arguments);
        final prefs = sl<SharedPreferences>();
        final rawUserData = prefs.getString(AppStorageKey.userData) ?? '';
        bool addedWorks = false;
        if (rawUserData.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawUserData);
            if (decoded is Map) {
              final value = decoded['added_works'];
              final normalized = value?.toString().toLowerCase().trim();
              addedWorks =
                  value == true || normalized == 'true' || normalized == '1';
            }
          } catch (_) {}
        }
        final isFreelancer = prefs.getBool(AppStorageKey.isFreelancer) ?? true;
        final shouldOpenSingleWork =
            isFreelancer && addedWorks && !arguments.fromOnboarding;
        if (shouldOpenSingleWork) {
          return _pageRoute(
            AddSingleWorkScreen(repository: sl<AddWorkRepo>()),
          );
        }
        return _pageRoute(
          AddYourProjects(
            arguments: arguments,
            isFreelancer: isFreelancer,
          ),
        );
      case Routes.freelancers:
        return _pageRoute(
          AllFreelancersView(
            arguments: FreelancersRouteArgs.fromRoute(settings.arguments),
            categoriesRepository: sl<HomeRepo>(),
            freelancersRepository: sl<HomeRepo>(),
            favouritesRepository: sl<FavouriteRepo>(),
          ),
        );
      case Routes.ownerProjects:
        return _pageRoute(OwnerProjects(
          arguments: ProjectListRouteArgs.fromRoute(settings.arguments),
          repository: sl<ProjectsRepo>(),
        ));
      case Routes.entrepreneur:
        return _pageRoute(EntrepreneurProfileView(
          arguments: EntrepreneurProfileArgs.fromRoute(settings.arguments),
          profileRepository: sl<HomeRepo>(),
          currentUserId: int.tryParse(
            sl<SharedPreferences>().getString(AppStorageKey.userId) ?? '',
          ),
          isFreelancer:
              sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                  false,
        ));
      case Routes.freeLancerView:
        return _pageRoute(FreelancerProfileView(
          arguments: FreelancerProfileArgs.fromRoute(settings.arguments),
          profileRepository: sl<HomeRepo>(),
          favouritesRepository: sl<FavouriteRepo>(),
        ));
      case Routes.chat:
        final chatArguments = ChatRouteArgs.fromRoute(settings.arguments);
        return _pageRoute(BlocProvider(
          create: (context) {
            return FreelancerChatBloc(
              repository: sl<ChatRepo>(),
              realtimeService: sl<PusherService>(),
            )..add(
                ConversationRequested(
                  conversationId: chatArguments.conversationId,
                  freelancerId: chatArguments.freelancerId,
                ),
              );
          },
          child: FreelancerChatScreen(
            arguments: chatArguments,
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        ));

      case Routes.editProfile:
        final preferences = sl<SharedPreferences>();
        return _pageRoute(
          EditProfileScreen(
            sharedPreferences: preferences,
            profileRepository: sl<UpdateProfileRepo>(),
            selectionOptionsRepository: sl<SelectionOptionRepo>(),
            locationOptionsRepository: sl<LocationOptionsRepo>(),
            initialImageUrl: preferences.getString(AppStorageKey.userImage),
          ),
        );
      case Routes.editWork:
        final workId = settings.arguments as int?;
        if (workId == null) {
          return _pageRoute(_homeView());
        }
        return _pageRoute(
          EditWorkScreen(
            workId: workId,
            workDetailsRepository: sl<HomeRepo>(),
            selectionOptionsRepository: sl<SelectionOptionRepo>(),
            workRepository: sl<AddWorkRepo>(),
          ),
        );

      case Routes.profile:
        final isFreelancer =
            sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                false;
        return _pageRoute(
          isFreelancer
              ? MyFreelancerProfileView(
                  profileRepository: sl<HomeRepo>(),
                )
              : EntrepreneurProfileView(
                  arguments: const EntrepreneurProfileArgs(
                    useCurrentProfile: true,
                  ),
                  profileRepository: sl<HomeRepo>(),
                  currentUserId: int.tryParse(
                    sl<SharedPreferences>().getString(AppStorageKey.userId) ??
                        '',
                  ),
                  isFreelancer: false,
                ),
        );
      case Routes.notifications:
        return _pageRoute(BlocProvider(
          create: (context) => NotificationBloc(
            repository: sl<NotificationRepo>(),
          ),
          child: const Notification(),
        ));
      case Routes.dashboard:
        return _pageRoute(
          DashboardScreen(
            repository: sl<DashboardRepo>(),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        );
      case Routes.work:
        final argument = settings.arguments;
        final mapArgument = argument is Map<String, dynamic> ? argument : null;
        final workFromMap = mapArgument?['work'];
        final workId = argument is int
            ? argument
            : argument is Work
                ? argument.id
                : workFromMap is Work
                    ? workFromMap.id
                    : mapArgument?['id'] as int?;
        final initialWork = argument is Work
            ? WorkDetailsModel.fromWork(argument)
            : workFromMap is Work
                ? WorkDetailsModel.fromWork(workFromMap)
                : null;
        final canEdit = mapArgument?['canEdit'] == true;
        if (workId == null) {
          return _pageRoute(_homeView());
        }
        return _pageRoute(WorkScreen(
          workId: workId,
          initialWork: initialWork,
          canEdit: canEdit,
          workDetailsRepository: sl<HomeRepo>(),
          favouritesRepository: sl<FavouriteRepo>(),
        ));
      case Routes.chats:
        return _pageRoute(BlocProvider(
          create: (context) => ChatsBloc(repository: sl<ChatsRepo>())
            ..add(const ChatsRequested()),
          child: const ChatScreen(),
        ));
      case Routes.bankAccounts:
        return _pageRoute(
          BankAccountsScreen(repository: sl<BankAccountsRepo>()),
        );
      case Routes.acceptanceTestQuestions:
        return _pageRoute(
          AcceptanceTestQuestionsScreen(
            arguments: AcceptanceTestRouteArgs.fromRoute(settings.arguments),
            acceptanceTestRepository: sl<AcceptanceTestRepository>(),
            workRepository: sl<AddWorkRepo>(),
          ),
        );
      case Routes.accountStatement:
        return _pageRoute(
          AccountStatementScreen(repository: sl<AccountStatementRepo>()),
        );
      case Routes.accountStatementDetails:
        final statementId = settings.arguments as int?;
        if (statementId == null) {
          return _pageRoute(
            AccountStatementScreen(repository: sl<AccountStatementRepo>()),
          );
        }
        return _pageRoute(
          AccountStatementDetailsScreen(
            statementId: statementId,
            repository: sl<AccountStatementRepo>(),
          ),
        );
      case Routes.contracts:
        return _pageRoute(_contractsScreen());
      case Routes.contractDetails:
        final contractId = settings.arguments as int?;
        if (contractId == null) {
          return _pageRoute(_contractsScreen());
        }
        return _pageRoute(
          ContractDetailsScreen(
            contractId: contractId,
            repository: sl<ContractsRepo>(),
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        );
      case Routes.contractPaymentRequest:
        final arguments = settings.arguments as ContractPaymentRequestArgs?;
        if (arguments == null) {
          return _pageRoute(_contractsScreen());
        }
        return _pageRoute(
          ContractPaymentRequestScreen(
            arguments: arguments,
            paymentRepository: sl<PaymentRepo>(),
            bankAccountsRepository: sl<BankAccountsRepo>(),
          ),
        );
      case Routes.contractPaymentConfirm:
        final arguments = settings.arguments as ContractPaymentConfirmArgs?;
        if (arguments == null) {
          return _pageRoute(_contractsScreen());
        }
        return _pageRoute(
          ContractPaymentConfirmScreen(
            arguments: arguments,
            paymentRepository: sl<PaymentRepo>(),
          ),
        );
      case Routes.createContract:
        return _pageRoute(
          CreateContractScreen(
            arguments: CreateContractRouteArgs.fromRoute(settings.arguments),
            addProjectRepository: sl<ProjectRepository>(),
            contractsRepository: sl<ContractsRepo>(),
          ),
        );
      case Routes.identityVerification:
        return _pageRoute(
          IdentityVerificationScreen(
            arguments: UserCompletionRouteArgs.fromRoute(settings.arguments),
            settingsRepository: sl<SettingsRepo>(),
            locationOptionsRepository: sl<LocationOptionsRepo>(),
            sharedPreferences: sl<SharedPreferences>(),
            dio: sl<Dio>(),
          ),
        );
      case Routes.brands:
        return _pageRoute(
          PartnerProfileView(
            partner: PartnerModel.fromJson(
              settings.arguments is Map
                  ? Map<String, dynamic>.from(
                      settings.arguments as Map,
                    )
                  : const <String, dynamic>{},
            ),
          ),
        );
      case Routes.terms:
        return _pageRoute(
          TermsAndConditionsScreen(repository: sl<TermsAndConditionRepo>()),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MyApp());
    }
  }

  static HomeView _homeView() => HomeView(
        repository: sl<HomeRepo>(),
        favouritesRepository: sl<FavouriteRepo>(),
        isFreelancer:
            sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                false,
      );

  static Login _login() => Login(
        repository: sl<LoginRepo>(),
        socialMediaRepository: sl<SocialMediaRepo>(),
        sessionStore: sl<AuthSessionStore>(),
        isFreelancer:
            sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? true,
      );

  static NavBar _navBar() => NavBar(
        homeRepository: sl<HomeRepo>(),
        favouritesRepository: sl<FavouriteRepo>(),
        projectsRepository: sl<ProjectsRepo>(),
        newProjectsRepository: sl<NewProjectsRepo>(),
        selectionOptionsRepository: sl<SelectionOptionRepo>(),
        settingsRepository: sl<SettingsRepo>(),
        authSessionStore: sl<AuthSessionStore>(),
        isFreelancer:
            sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                false,
      );

  static ContractsScreen _contractsScreen() => ContractsScreen(
        repository: sl<ContractsRepo>(),
      );

  static _pageRoute(Widget child) => Platform.isIOS
      ? CupertinoPageRoute(builder: (_) => child)
      : MaterialPageRoute(builder: (_) => child);

  static pop({dynamic result}) {
    if (navigatorState.currentState!.canPop()) {
      navigatorState.currentState!.pop(result);
    }
  }

  static push(String routeName,
      {arguments, bool replace = false, bool clean = false}) {
    if (clean) {
      return navigatorState.currentState!.pushNamedAndRemoveUntil(
          routeName, (_) => false,
          arguments: arguments);
    } else if (replace) {
      return navigatorState.currentState!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } else {
      return navigatorState.currentState!
          .pushNamed(routeName, arguments: arguments);
    }
  }
}
