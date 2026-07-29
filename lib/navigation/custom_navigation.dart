import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart' hide Notification;
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/auth/pages/register/register.dart';
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
import 'package:talent_flow/features/setting/bloc/notification_bloc.dart';
import 'package:talent_flow/features/setting/bloc/chats_bloc.dart';
import 'package:talent_flow/features/setting/repo/chats_repo.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';
import 'package:talent_flow/features/setting/repo/bank_accounts_repo.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';
import 'package:talent_flow/features/setting/repo/acceptance_test_repo.dart';
import 'package:talent_flow/features/setting/page/add_projects.dart';
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
import '../main_repos/location_options_repo.dart';
import '../features/on_boarding/page/free_lancer_screen.dart';
import '../features/on_boarding/page/on_boarding_screen.dart';
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
          arguments: settings.arguments as Map<String, dynamic>?,
        ));
      case Routes.navBar:
        return _pageRoute(_navBar());
      case Routes.home:
        return _pageRoute(_homeView());
      case Routes.splash:
        return _pageRoute(const Splash());
      case Routes.login:
        return _pageRoute(const Login());
      case Routes.register:
        return _pageRoute(const Register());
      case Routes.forgetPassword:
        return _pageRoute(ChangePasswordScreen(
          arguments: settings.arguments as Map<String, dynamic>,
        ));

      case Routes.verificationScreen:
        return _pageRoute(const SendVerificationScreen());
      case Routes.singleProjectDetails:
        return _pageRoute(SingleProjectView(
          arguments: settings.arguments as Map<String, dynamic>,
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
          argument: settings.arguments as Map<String, dynamic>,
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
            argument: settings.arguments as Map<String, dynamic>,
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
        final arguments = settings.arguments as Map<String, dynamic>?;
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
            isFreelancer && addedWorks && arguments?['fromOnboarding'] != true;
        if (shouldOpenSingleWork) {
          return _pageRoute(
            AddSingleWorkScreen(repository: sl<AddWorkRepo>()),
          );
        }
        return _pageRoute(
          AddYourProjects(
            arguments: arguments,
          ),
        );
      case Routes.freelancers:
        return _pageRoute(
          AllFreelancersView(
            arguments: settings.arguments as Map<String, dynamic>?,
            categoriesRepository: sl<HomeRepo>(),
            freelancersRepository: sl<HomeRepo>(),
            favouritesRepository: sl<FavouriteRepo>(),
          ),
        );
      case Routes.ownerProjects:
        return _pageRoute(OwnerProjects(
          arguments: settings.arguments as Map<String, dynamic>?,
          repository: sl<ProjectsRepo>(),
        ));
      case Routes.entrepreneur:
        return _pageRoute(EntrepreneurProfileView(
          arguments: settings.arguments as Map<String, dynamic>?,
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
          arguments: settings.arguments as Map<String, dynamic>,
          profileRepository: sl<HomeRepo>(),
          favouritesRepository: sl<FavouriteRepo>(),
        ));
      case Routes.chat:
        return _pageRoute(BlocProvider(
          create: (context) {
            final chatArguments = settings.arguments as Map<String, dynamic>?;
            int? parseId(Object? value) =>
                value is int ? value : int.tryParse(value?.toString() ?? '');
            return FreelancerChatBloc(
              repository: sl<ChatRepo>(),
              realtimeService: sl<PusherService>(),
            )..add(
                ConversationRequested(
                  conversationId: parseId(chatArguments?['conversationId']),
                  freelancerId: parseId(chatArguments?['freelancerId']),
                ),
              );
          },
          child: FreelancerChatScreen(
            arguments: settings.arguments as Map<String, dynamic>?,
            isFreelancer:
                sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                    false,
          ),
        ));

      //
      // case Routes.splash:
      //   return _pageRoute(const Splash());
      //
      // case Routes.login:
      //   return _pageRoute(Login());
      //
      // case Routes.register:
      //   return _pageRoute(const Register());
      //
      // case Routes.forgetPassword:
      //   return _pageRoute(const ForgetPassword());
      //
      // case Routes.resetPassword:
      //   return _pageRoute(ResetPassword(
      //     data: settings.arguments as VerificationModel,
      //   ));
      //
      // case Routes.changePassword:
      //   return _pageRoute(const ChangePassword());
      //
      // case Routes.verification:
      //   return _pageRoute(Verification(model: settings.arguments as VerificationModel));
      //
      case Routes.editProfile:
        return _pageRoute(const EditProfileScreen());
      case Routes.editWork:
        final workId = settings.arguments as int?;
        if (workId == null) {
          return _pageRoute(_homeView());
        }
        return _pageRoute(EditWorkScreen(workId: workId));

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
                  arguments: const {'useCurrentProfile': true},
                  profileRepository: sl<HomeRepo>(),
                  currentUserId: int.tryParse(
                    sl<SharedPreferences>().getString(AppStorageKey.userId) ??
                        '',
                  ),
                  isFreelancer: false,
                ),
        );
      // case Routes.dashboard:
      //   return _pageRotute(DashBoard(
      //     index: settings.arguments as int?,
      //   ));
      //
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
            arguments: settings.arguments as Map<String, dynamic>?,
            acceptanceTestRepo: sl<AcceptanceTestRepo>(),
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
            arguments: settings.arguments as Map<String, dynamic>?,
            addProjectRepository: sl<ProjectRepository>(),
            contractsRepository: sl<ContractsRepo>(),
          ),
        );
      case Routes.identityVerification:
        return _pageRoute(
          IdentityVerificationScreen(
            arguments: settings.arguments as Map<String, dynamic>?,
            settingsRepository: sl<SettingsRepo>(),
            locationOptionsRepository: sl<LocationOptionsRepo>(),
            sharedPreferences: sl<SharedPreferences>(),
            dio: sl<Dio>(),
          ),
        );
      //
      // case Routes.services:
      //   return _pageRoute(const ServicesPage());
      //
      // case Routes.offers:
      //   return _pageRoute(const OffersPage());
      //
      case Routes.brands:
        return _pageRoute(
          PartnerProfileView(
            arguments: settings.arguments as Map<String, dynamic>?,
          ),
        );
      //
      // case Routes.newsDetails:
      //   return _pageRoute(NewsDetailsPage(id: settings.arguments as int));
      //
      // case Routes.courses:
      //   return _pageRoute(const CoursesPage());
      //
      // case Routes.myCourses:
      //   return _pageRoute(const MyCoursesPage());
      //
      // case Routes.courseDetails:
      //   return _pageRoute(CourseDetailsPage(id: settings.arguments as int));
      //
      // case Routes.associations:
      //   return _pageRoute(const AssociationsPage());
      //
      // case Routes.myAssociations:
      //   return _pageRoute(const MyAssociationsPage());
      //
      // case Routes.associationDetails:
      //   return _pageRoute(AssociationDetailsPage(id: settings.arguments as int));
      //
      // case Routes.conferences:
      //   return _pageRoute(const ConferencesPage());
      //
      // case Routes.myConferences:
      //   return _pageRoute(const MyConferencesPage());
      //
      // case Routes.conferenceDetails:
      //   return _pageRoute(ConferenceDetailsPage(id: settings.arguments as int));
      //
      // case Routes.addMembershipRequest:
      //   return _pageRoute(AddMembershipRequestPage(model: settings.arguments as MembershipRequestModel?));
      //
      // case Routes.addAssociationRequest:
      //   return _pageRoute(AddAssociationRequestPage(model: settings.arguments as AssociationModel?));
      //
      // case Routes.addStudentMembershipRequest:
      //   return _pageRoute(AddStudentMembershipRequestPage(model: settings.arguments as MembershipRequestModel?));
      //
      // case Routes.updateMembership:
      //   return _pageRoute(UpdateMembershipPage(model: settings.arguments as MembershipRequestModel?));
      //
      // case Routes.addEducationalData:
      //   return _pageRoute(AddEducationalDataPage(data: settings.arguments as Map<String, dynamic>));
      //
      // case Routes.addExperienceData:
      //   return _pageRoute(AddExperienceDataPage(data: settings.arguments as Map<String, dynamic>));
      //
      // case Routes.membershipRequest:
      //   return _pageRoute(const MembershipRequestPage());
      //
      // case Routes.videoPreview:
      //   return _pageRoute(VideoPreviewPage(data: settings.arguments as Map));
      //
      // case Routes.pickLocation:
      //   return _pageRoute(PickMapPage(data: settings.arguments as LocationModel));
      //
      // case Routes.payment:
      //   return _pageRoute(InAppViewPage(url: settings.arguments as String));
      //
      // case Routes.whoUs:
      //   return _pageRoute(WhoUsPage(
      //     index: settings.arguments as int?,
      //   ));
      //
      // case Routes.contactWithUs:
      //   return _pageRoute(const ContactWithUsPage());
      //
      // case Routes.privacy:
      //   return _pageRoute(const PrivacyPolicy());
      //
      case Routes.terms:
        return _pageRoute(
          TermsAndConditionsScreen(repository: sl<TermsAndConditionRepo>()),
        );
      //
      // case Routes.faqs:
      //   return _pageRoute(const FaqsPage());

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

  static NavBar _navBar() => NavBar(
        homeRepository: sl<HomeRepo>(),
        favouritesRepository: sl<FavouriteRepo>(),
        projectsRepository: sl<ProjectsRepo>(),
        newProjectsRepository: sl<NewProjectsRepo>(),
        selectionOptionsRepository: sl<SelectionOptionRepo>(),
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

  // static PageRouteBuilder<dynamic> _pageRoute(Widget child) => PageRouteBuilder(
  //     transitionDuration: const Duration(milliseconds: 100),
  //     reverseTransitionDuration: const Duration(milliseconds: 100),
  //     transitionsBuilder: (c, anim, a2, child) {
  //       var begin = const Offset(1.0, 0.0);
  //       var end = Offset.zero;
  //       var tween = Tween(begin: begin, end: end);
  //       var curveAnimation =
  //           CurvedAnimation(parent: anim, curve: Curves.linearToEaseOut);
  //       return SlideTransition(
  //         position: tween.animate(curveAnimation),
  //         child: child,
  //       );
  //     },
  //     opaque: false,
  //     pageBuilder: (_, __, ___) => child);

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
