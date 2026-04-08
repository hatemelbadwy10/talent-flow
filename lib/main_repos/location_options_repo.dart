import 'package:dartz/dartz.dart';

import '../data/api/end_points.dart';
import '../data/error/api_error_handler.dart';
import '../data/error/failures.dart';
import '../main_models/location_option_model.dart';
import 'base_repo.dart';

class LocationOptionsRepo extends BaseRepo {
  LocationOptionsRepo({
    required super.sharedPreferences,
    required super.dioClient,
  });

  Future<Either<Failure, Map<String, String>>> getCountries() async {
    try {
      final response = await dioClient.get(uri: EndPoints.countries);
      return Right(_parseOptions(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Future<Either<Failure, Map<String, String>>> getCities(
      String countryId) async {
    try {
      final response = await dioClient.get(
        uri: EndPoints.countryCities(countryId),
      );
      return Right(_parseOptions(response.data));
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  Map<String, String> _parseOptions(dynamic raw) {
    final payload = raw is Map<String, dynamic> && raw['payload'] != null
        ? raw['payload']
        : raw;

    if (payload is Map) {
      return payload.map(
        (key, value) => MapEntry(
          key.toString(),
          value?.toString() ?? '',
        ),
      );
    }

    if (payload is List) {
      final entries = payload
          .whereType<Map>()
          .map((item) => LocationOptionModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty);

      return {
        for (final item in entries) item.id: item.name,
      };
    }

    return const {};
  }
}
