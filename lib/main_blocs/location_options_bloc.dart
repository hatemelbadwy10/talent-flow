import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/error/failures.dart';
import '../main_repos/location_options_repo.dart';

class LocationOptionsBloc
    extends Bloc<LocationOptionsEvent, LocationOptionsState> {
  LocationOptionsBloc(this._repo) : super(const LocationOptionsState()) {
    on<LoadCountries>(_onLoadCountries);
    on<LoadCities>(_onLoadCities);
    on<ClearCities>(_onClearCities);
  }

  final LocationOptionsRepo _repo;

  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<LocationOptionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingCountries: true,
        clearCountriesError: true,
      ),
    );

    final result = await _repo.getCountries();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingCountries: false,
          countriesError:
              failure is ServerFailure ? failure.error : failure.toString(),
        ),
      ),
      (countries) => emit(
        state.copyWith(
          isLoadingCountries: false,
          countries: countries,
          clearCountriesError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<LocationOptionsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingCities: true,
        selectedCountryId: event.countryId,
        clearCitiesError: true,
        cities: const {},
      ),
    );

    final result = await _repo.getCities(event.countryId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingCities: false,
          citiesError:
              failure is ServerFailure ? failure.error : failure.toString(),
        ),
      ),
      (cities) => emit(
        state.copyWith(
          isLoadingCities: false,
          cities: cities,
          clearCitiesError: true,
        ),
      ),
    );
  }

  void _onClearCities(
    ClearCities event,
    Emitter<LocationOptionsState> emit,
  ) {
    emit(
      state.copyWith(
        cities: const {},
        selectedCountryId: null,
        clearCitiesError: true,
        isLoadingCities: false,
      ),
    );
  }
}

abstract class LocationOptionsEvent extends Equatable {
  const LocationOptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountries extends LocationOptionsEvent {
  const LoadCountries();
}

class LoadCities extends LocationOptionsEvent {
  const LoadCities({required this.countryId});

  final String countryId;

  @override
  List<Object?> get props => [countryId];
}

class ClearCities extends LocationOptionsEvent {
  const ClearCities();
}

class LocationOptionsState extends Equatable {
  const LocationOptionsState({
    this.countries = const {},
    this.cities = const {},
    this.isLoadingCountries = false,
    this.isLoadingCities = false,
    this.countriesError,
    this.citiesError,
    this.selectedCountryId,
  });

  final Map<String, String> countries;
  final Map<String, String> cities;
  final bool isLoadingCountries;
  final bool isLoadingCities;
  final String? countriesError;
  final String? citiesError;
  final String? selectedCountryId;

  LocationOptionsState copyWith({
    Map<String, String>? countries,
    Map<String, String>? cities,
    bool? isLoadingCountries,
    bool? isLoadingCities,
    String? countriesError,
    String? citiesError,
    String? selectedCountryId,
    bool clearCountriesError = false,
    bool clearCitiesError = false,
  }) {
    return LocationOptionsState(
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      countriesError:
          clearCountriesError ? null : (countriesError ?? this.countriesError),
      citiesError: clearCitiesError ? null : (citiesError ?? this.citiesError),
      selectedCountryId: selectedCountryId ?? this.selectedCountryId,
    );
  }

  @override
  List<Object?> get props => [
        countries,
        cities,
        isLoadingCountries,
        isLoadingCities,
        countriesError,
        citiesError,
        selectedCountryId,
      ];
}
