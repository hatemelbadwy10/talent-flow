import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/features/auth/pages/confirm_code/repo/confirm_code_repo.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/chat_repo.dart';
import 'package:talent_flow/features/auth/pages/social_media_login/repo/social_media_repo.dart';
import 'package:talent_flow/features/home/bloc/home_bloc.dart';
import 'package:talent_flow/features/home/repo/home_repo.dart';
import 'package:talent_flow/features/new_projects/repo/new_projects_repo.dart';
import 'package:talent_flow/features/new_projects/repo/selection_option_repo.dart';
import 'package:talent_flow/features/payment/repo/pay_ment_repo.dart';
import 'package:talent_flow/features/projects/repo/projects_repo.dart';
import 'package:talent_flow/features/setting/repo/about_repo.dart';
import 'package:talent_flow/features/setting/repo/account_statement_repo.dart';
import 'package:talent_flow/features/setting/repo/add_word_repo.dart';
import 'package:talent_flow/features/setting/repo/bank_accounts_repo.dart';
import 'package:talent_flow/features/setting/repo/chats_repo.dart';
import 'package:talent_flow/features/setting/repo/contracts_repo.dart';
import 'package:talent_flow/features/setting/repo/dashboard_repo.dart';
import 'package:talent_flow/features/setting/repo/favourite_repo.dart';
import 'package:talent_flow/features/setting/repo/notification_repo.dart';
import 'package:talent_flow/features/setting/repo/terms_condation_repo.dart';
import 'package:talent_flow/features/setting/repo/update_profile_repo.dart';
import 'package:talent_flow/main_blocs/user_bloc.dart';
import 'package:talent_flow/main_repos/user_repo.dart';
import '../../features/auth/pages/change_password/repo/change_password_repo.dart';
import '../../features/auth/pages/login/repo/login_repo.dart';
import '../../features/auth/pages/register/repo/register_repo.dart';
import '../../features/auth/pages/send_verification/send_verification_repo/send_verification_repo.dart';
import '../../features/new_projects/bloc/add_project_bloc.dart';
import '../../features/new_projects/repo/add_project_repo.dart';
import '../../features/setting/repo/settings_repo.dart';
import '../../features/splash/repo/splash_repo.dart';
import '../../helpers/social_media_login_helper.dart';
import '../api/end_points.dart';
import '../realtime/pusher_service.dart';
import '../internet_connection/internet_connection.dart';
import '../local_data/local_database.dart';
import '../dio/dio_client.dart';
import '../dio/logging_interceptor.dart';
import '../securty/secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  _registerExternalDependencies(sharedPreferences);
  _registerCoreDependencies();
  _registerHomeDependencies();
  _registerAuthDependencies();
  _registerProjectsAndPaymentsDependencies();
  _registerSettingsDependencies();
  _registerGlobalDependencies();
}

void _registerExternalDependencies(SharedPreferences sharedPreferences) {
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage(flutterSecureStorage: sl()));
  sl.registerLazySingleton(() => LoggingInterceptor());
}

void _registerCoreDependencies() {
  sl.registerLazySingleton(() => LocaleDatabase());
  sl.registerLazySingleton(() => DioClient(
        EndPoints.baseUrl,
        dio: sl(),
        loggingInterceptor: sl(),
        sharedPreferences: sl(),
      ));
  sl.registerLazySingleton(() => SocialMediaLoginHelper());
  sl.registerLazySingleton(() => InternetConnection(connectivity: sl()));
  sl.registerLazySingleton(() => PusherService(dioClient: sl()));
}

void _registerHomeDependencies() {
  sl.registerLazySingleton(
      () => HomeRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerFactory(() => HomeBloc(homeRepo: sl()));
  sl.registerLazySingleton(
      () => NewProjectsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => TermsAndConditionRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => AboutRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ProjectRepository(dioClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton(
      () => SelectionOptionRepo(dioClient: sl(), sharedPreferences: sl()));
  sl.registerFactory(() => AddProjectBloc(repository: sl()));
}

void _registerAuthDependencies() {
  sl.registerLazySingleton(
      () => LoginRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => RegisterRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ConfirmCodeRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => SendVerificationRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ChangePasswordRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(() => SocialMediaRepo(
      socialMediaLoginHelper: sl(), sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ChatRepo(sharedPreferences: sl(), dioClient: sl()));
}

void _registerProjectsAndPaymentsDependencies() {
  sl.registerLazySingleton(
      () => ProjectsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => PaymentRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => SplashRepo(sharedPreferences: sl(), dioClient: sl()));
}

void _registerSettingsDependencies() {
  sl.registerLazySingleton(
      () => UpdateProfileRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => SettingsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => AddWorkRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => FavouriteRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => NotificationRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ChatsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => ContractsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => AccountStatementRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => BankAccountsRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(
      () => DashboardRepo(sharedPreferences: sl(), dioClient: sl()));
}

void _registerGlobalDependencies() {
  sl.registerLazySingleton(
      () => UserRepo(sharedPreferences: sl(), dioClient: sl()));
  sl.registerLazySingleton(() => UserBloc(repo: sl()));
}
