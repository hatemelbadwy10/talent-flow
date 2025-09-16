import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/repo/home_repo.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';
import 'package:talent_flow/features/new_projects/repo/selection_option_repo.dart';
import 'package:talent_flow/features/projects/repo/projects_repo.dart';
import 'package:talent_flow/features/setting/repo/about_repo.dart';
import 'package:talent_flow/features/setting/repo/terms_condation_repo.dart';
import '../../features/auth/pages/change_password/repo/change_password_repo.dart';
import '../../features/auth/pages/login/repo/login_repo.dart';
import '../../features/auth/pages/register/repo/register_repo.dart';
import '../../features/auth/pages/send_verification/send_verification_repo/send_verification_repo.dart';
import '../../features/new_projects/bloc/add_project_bloc.dart';
import '../../features/new_projects/repo/add_project_repo.dart';
import '../../features/splash/repo/splash_repo.dart';
import '../../helpers/social_media_login_helper.dart';
import '../api/end_points.dart';
import '../internet_connection/internet_connection.dart';
import '../local_data/local_database.dart';
import '../dio/dio_client.dart';
import '../dio/logging_interceptor.dart';
import '../securty/secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => LocaleDatabase());
  sl.registerLazySingleton(() => DioClient(
        EndPoints.baseUrl,
        dio: sl(),
        loggingInterceptor: sl(),
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton(() => SocialMediaLoginHelper());
  sl.registerLazySingleton(() => InternetConnection(connectivity: sl()));

  // /// Repository
  // sl.registerLazySingleton(() => LocalizationRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  sl.registerLazySingleton(() => HomeRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerFactory(()=>HomeBloc(homeRepo: sl()));
  sl.registerLazySingleton(()=>NewProjectsRepo(sharedPreferences:sl(), dioClient: sl()));
  sl.registerLazySingleton(()=>TermsAndConditionRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(()=>AboutRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(()=>ProjectRepository( dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(()=>SelectionOptionRepo( dioClient: sl(), sharedPreferences: sl()));

  //
  // sl.registerLazySingleton(() => DashboardRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => DeleteFileRepo(sharedPreferences: sl(), dioClient: sl()));
  // sl.registerLazySingleton(() => FaqsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => DownloadRepo());
  //
  // sl.registerLazySingleton(() => SelectorsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => PickerHelperRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  sl.registerLazySingleton(() => SplashRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  sl.registerLazySingleton(() => ProjectsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
   sl.registerLazySingleton(() => LoginRepo(sharedPreferences: sl(), dioClient: sl()));
  //
   sl.registerLazySingleton(() => RegisterRepo(sharedPreferences: sl(), dioClient: sl()));
  //
   sl.registerLazySingleton(() => ConfirmCodeRepo(sharedPreferences: sl(), dioClient: sl()));
  //
   sl.registerLazySingleton(() => SendVerificationRepo(sharedPreferences: sl(), dioClient: sl()));
  //
   sl.registerLazySingleton(() => ChangePasswordRepo(sharedPreferences: sl(), dioClient: sl()));
   sl.registerFactory(()=>AddProjectBloc( repository: sl()));
  //
  // sl.registerLazySingleton(() => ChangePasswordRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => LogoutRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ActivationAccountRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ProfileRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => EditProfileRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MapsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(
  //     () => SocialMediaRepo(sharedPreferences: sl(), dioClient: sl(), socialMediaLoginHelper: sl()));
  //
  // sl.registerLazySingleton(() => DeactivateAccountRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ServicesRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => OffersRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => PartnersRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => NewsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => NewsDetailsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => NotificationsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => BannersRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MembershipRequestsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AddMembershipRequestRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AddStudentMembershipRequestRepo(sharedPreferences: sl(), dioClient: sl()));
  // sl.registerLazySingleton(() => AddAssociationRequestRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => UpdateGeneralDataRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => EducationalDataRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AddEducationalDataRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ExperienceDataRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AddExperienceDataRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => CompleteMembershipRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => SubscriptionsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => SubscribeRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ContactWithUsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => BoardMembersRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MembershipInstructionsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => CoursesRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MyCoursesRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => CourseDetailsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AssociationsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MyAssociationsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AssociationDetailsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ConferencesRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => MyConferencesRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => ConferenceDetailsRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => AddConferenceRequestRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // sl.registerLazySingleton(() => CheckOutRepo(sharedPreferences: sl(), dioClient: sl()));
  //
  // //provider
  // sl.registerLazySingleton(() => LanguageBloc(repo: sl()));
  // sl.registerLazySingleton(() => ThemeProvider(sharedPreferences: sl()));
  // sl.registerLazySingleton(() => DashboardBloc(repo: sl()));
  // sl.registerLazySingleton(() => ProfileBloc(repo: sl()));
  // sl.registerLazySingleton(() => UserBloc(repo: sl()));
  // sl.registerLazySingleton(() => BannersBloc(repo: sl(), internetConnection: sl()));
  // sl.registerLazySingleton(() => MembershipInstructionsBloc(repo: sl(), internetConnection: sl()));
  //
  // ///Log out
  // sl.registerLazySingleton(() => LogoutBloc(repo: sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage(flutterSecureStorage: sl()));
  sl.registerLazySingleton(() => LoggingInterceptor());
}
