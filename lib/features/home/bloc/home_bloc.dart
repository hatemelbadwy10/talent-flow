import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/app_event.dart';
import 'package:talent_flow/app/core/app_state.dart';
import 'dart:developer';
import '../model/entrepreneur_profile_model.dart';
import '../model/freelancer_profile_model.dart';
import '../model/freelancers_model.dart';
import '../model/home_model.dart';
import '../model/work_details_model.dart';
import '../repo/home_repo.dart';

class HomeBloc extends Bloc<AppEvent, AppState> {
  final HomeRepo _homeRepo;

  HomeBloc({required HomeRepo homeRepo})
      : _homeRepo = homeRepo,
        super(Start()) {
    on<Add>(_onGetHomeData);
    on<Click>(onClick);
    on<Follow>(onGetFreelancers);
    on<FreelancerProfile>(onGetFreelancerProfile);
    on<EntrepreneurProfileEvent>(onGetEntrepreneurProfile);
    on<Open>(onGetWorkDetails);
  }

  Future<void> _onGetHomeData(Add event, Emitter<AppState> emit) async {
    emit(Loading());

    try {
      log('🟡 Starting home data request...');
      final result = await _homeRepo.getHome();
      log("🟢 Repository request finished");

      result.fold(
        (failure) {
          log('🔴 HomeBloc Error - Failure: ${failure.error}');
          emit(Error());
        },
        (response) {
          try {
            log('🟢 Raw response data: ${response.data}');

            // Check if response.data is null
            if (response.data == null) {
              log('🔴 Response data is null');
              emit(Error());
              return;
            }

            // Check if response.data has the expected structure
            if (response.data is! Map<String, dynamic>) {
              log('🔴 Response data is not a Map<String, dynamic>');
              emit(Error());
              return;
            }

            final Map<String, dynamic> responseData =
                response.data as Map<String, dynamic>;

            // Check if payload exists
            if (!responseData.containsKey('payload')) {
              log('🔴 Response data does not contain payload key');
              emit(Error());
              return;
            }

            // Extract payload
            final payload = responseData['payload'];
            if (payload == null) {
              log('🔴 Payload is null');
              emit(Error());
              return;
            }

            log('🟢 Payload: $payload');

            // Create HomeModel from payload instead of response.data
            final homeModel = HomeModel.fromJson(payload);
            log('🟢 HomeModel created successfully');
            log('🟢 Categories count: ${homeModel.categories.length}');
            log('🟢 Cards count: ${homeModel.cards.length}');
            log('🟢 Top items count: ${homeModel.top?.items.length ?? 0}');

            emit(Done(model: homeModel, reload: false, loading: false));
          } catch (e, stackTrace) {
            log('🔴 Error parsing HomeModel: $e');
            log('🔴 Stack trace: $stackTrace');
            emit(Error());
          }
        },
      );
    } catch (e, stackTrace) {
      log('🔴 Unexpected error in _onGetHomeData: $e');
      log('🔴 Stack trace: $stackTrace');
      emit(Error());
    }
  }

  Future<void> onClick(Click event, Emitter<AppState> emit) async {
    emit(Loading());

    try {
      final result = await _homeRepo.getCategories();

      result.fold(
        (failure) {
          emit(Error());
        },
        (response) {
          try {
            if (response.data == null) {
              emit(Error());
              return;
            }

            if (response.data is! Map<String, dynamic>) {
              emit(Error());
              return;
            }

            final Map<String, dynamic> responseData = response.data;

            // Check if payload exists
            if (!responseData.containsKey('payload')) {
              emit(Error());
              return;
            }

            // Extract payload
            final payload = responseData['payload'];
            if (payload == null) {
              log('🔴 Payload is null');
              emit(Error());
              return;
            }

            log('🟢 Payload: $payload');

            // Parse categories model
            if (payload is List) {
              final categories = payload
                  .map(
                      (item) => Category.fromJson(item as Map<String, dynamic>))
                  .toList();

              log('🟢 Categories parsed: ${categories.length}');
              emit(Done(list: categories, reload: false, loading: false));
            } else {
              log('🔴 Payload is not a list');
              emit(Error());
            }
          } catch (e, stackTrace) {
            log('🔴 Error parsing CategoriesModel: $e');
            log('🔴 Stack trace: $stackTrace');
            emit(Error());
          }
        },
      );
    } catch (e, stackTrace) {
      log('🔴 Unexpected error in onClick: $e');
      log('🔴 Stack trace: $stackTrace');
      emit(Error());
    }
  }

  Future<void> onGetFreelancers(Follow event, Emitter<AppState> emit) async {
    emit(Loading());

    try {
      // اقرأ الـ categoryId من event.arguments (ممكن ييجي null عادي)

      final categoryId = event.arguments as int?;
      // ننده على الريبو ونبعتله الـ categoryId (ممكن null)
      final result = await _homeRepo.getFreelancers(categoryId: categoryId);

      result.fold(
        (failure) => emit(Error()),
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }

          final payload = categoryId == null
              ? response.data['payload']
              : response.data['payload']['items'];

          if (payload is! List) {
            emit(Error());
            return;
          }

          final freelancers =
              payload.map((e) => FreelancersModel.fromJson(e)).toList();

          emit(Done(list: freelancers, reload: false, loading: false));
        },
      );
    } catch (e, s) {
      log("🔴 Error in onGetFreelancers: $e\n$s");
      emit(Error());
    }
  }

  Future<void> onGetFreelancerProfile(
      FreelancerProfile event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final freelancerId = event.arguments as int;
      final result = await _homeRepo.getFreelancerProfile(freelancerId);
      result.fold(
        (failure) => emit(Error()),
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }
          final payload = response.data['payload'];
          if (payload is! Map<String, dynamic>) {
            emit(Error());
            return;
          }
          final freelancerProfile = FreelancerProfileModel.fromJson(payload);
          emit(Done(model: freelancerProfile, reload: false, loading: false));
        },
      );
    } catch (e, s) {
      log("🔴 Error in onGetFreelancerProfile: $e\n$s");
      emit(Error());
    }
  }

  Future<void> onGetEntrepreneurProfile(
      EntrepreneurProfileEvent event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final entrepreneurId = event.arguments as int;
      final result = await _homeRepo.getEntrepreneurProfile(entrepreneurId);
      result.fold(
        (failure) => emit(Error()),
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }
          final payload = response.data['payload'];
          if (payload is! Map<String, dynamic>) {
            emit(Error());
            return;
          }
          final entrepreneurProfile =
              EntrepreneurProfileModel.fromJson(payload);
          emit(Done(model: entrepreneurProfile, reload: false, loading: false));
        },
      );
    } catch (e, s) {
      log("🔴 Error in onGetEntrepreneurProfile: $e\n$s");
      emit(Error());
    }
  }

  Future<void> onGetWorkDetails(Open event, Emitter<AppState> emit) async {
    emit(Loading());
    try {
      final workId = event.arguments as int;
      final result = await _homeRepo.getWorkDetails(workId);
      result.fold(
        (failure) => emit(Error()),
        (response) {
          if (response.data == null || response.data['payload'] == null) {
            emit(Error());
            return;
          }
          final payload = response.data['payload'];
          if (payload is! Map<String, dynamic>) {
            emit(Error());
            return;
          }
          final workDetails = WorkDetailsModel.fromJson(payload);
          emit(Done(model: workDetails, reload: false, loading: false));
        },
      );
    } catch (e, s) {
      log("🔴 Error in onGetWorkDetails: $e\n$s");
      emit(Error());
    }
  }
}
