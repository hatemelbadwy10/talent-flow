import 'dart:io';
import 'package:flutter/cupertino.dart' hide Notification;
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/auth/pages/register/register.dart';
import 'package:talent_flow/features/new_projects/page/add_project.dart';
import 'package:talent_flow/features/payment/page/payment_page.dart';
import 'package:talent_flow/features/projects/bloc/my_projects_bloc.dart';
import 'package:talent_flow/features/projects/page/single_project_view.dart';
import 'package:talent_flow/features/setting/bloc/notification_bloc.dart';
import 'package:talent_flow/features/setting/page/add_projects.dart';
import 'package:talent_flow/features/setting/page/favourite.dart';
import 'package:talent_flow/features/setting/page/notification.dart';
import '../app/core/app_event.dart';
import '../data/config/di.dart';
import '../features/auth/pages/change_password/change_password.dart';
import '../features/auth/pages/confirm_code/confrim_code.dart';
import '../features/auth/pages/login/login.dart';
import '../features/auth/pages/send_verification/send_verification.dart';
import '../features/home/page/all_categories.dart';
import '../features/home/page/all_freelancers_view.dart';
import '../features/home/page/entrepreneur_profile.dart';
import '../features/home/page/freelancer_profile.dart';
import '../features/home/page/home_view.dart';
import '../features/nav_bar/page/nav_bar.dart';
import '../features/new_projects/bloc/new_projects_bloc.dart';
import '../features/new_projects/page/add_offer_screen.dart';
import '../features/on_boarding/page/free_lancer_screen.dart';
import '../features/on_boarding/page/on_boarding_screen.dart';
import '../features/projects/page/my_projects.dart';
import '../features/setting/page/about_talent_flow.dart';
import '../features/setting/page/edit_profile.dart';
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
        return _pageRoute(const NavBar());
      case Routes.home:
        return _pageRoute(const HomeView());
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
        ));
      case Routes.payment:
        return _pageRoute(const PaymentPage());
      case Routes.about:
        return _pageRoute(const AboutTalentFlowView());
      case Routes.favorites:
        return _pageRoute(const Favourite());
      case Routes.sendCodeScreen:
        return _pageRoute(ConfirmCodeScreen(
          argument: settings.arguments as Map<String, dynamic>,
        ));
      case Routes.allCategories:
        return _pageRoute(const ServiceCategoryView());
      case Routes.addOffer:
        return _pageRoute(BlocProvider(
          create: (context) => NewProjectsBloc(sl()),
          child: AddOfferScreen(
            argument: settings.arguments as Map<String, dynamic>,
          ),
        ));
      case Routes.addProject:
        return _pageRoute(const AddProject());
      case Routes.addYourProject:
        return _pageRoute(const AddYourProjects());
      case Routes.freelancers:
        return _pageRoute(AllFreelancersView(
            arguments: settings.arguments as Map<String, dynamic>?)
        );
      case Routes.ownerProjects:
        return _pageRoute(BlocProvider(
          create: (context) =>
          MyProjectsBloc(sl())
            ..add(Add()),
          child: OwnerProjects(
            arguments: settings.arguments as Map<String, dynamic>?,),
        ));
      case Routes.entrepreneur:
        return _pageRoute(const EntrepreneurProfile());
      case Routes.freeLancerView:
        return _pageRoute(FreelancerProfileView(
          arguments: settings.arguments as Map<String, dynamic>,));

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

    // case Routes.profile:
    //   return _pageRoute(const MyProfile());
    //
    // case Routes.dashboard:
    //   return _pageRotute(DashBoard(
    //     index: settings.arguments as int?,
    //   ));
    //
      case Routes.notifications:
        return _pageRoute(BlocProvider(
          create: (context) => NotificationBloc(sl()),
          child: const Notification(),
        ));
    //
    // case Routes.services:
    //   return _pageRoute(const ServicesPage());
    //
    // case Routes.offers:
    //   return _pageRoute(const OffersPage());
    //
    // case Routes.brands:
    //   return _pageRoute(const PartnersPage());
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
        return _pageRoute(const TermsAndConditionsScreen());
    //
    // case Routes.faqs:
    //   return _pageRoute(const FaqsPage());

      default:
        return MaterialPageRoute(builder: (_) => const MyApp());
    }
  }

  static _pageRoute(Widget child) =>
      Platform.isIOS
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
