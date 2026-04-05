import 'package:dio/dio.dart';
import '../../app/localization/language_constant.dart';
import 'failures.dart';

class ApiErrorHandler {
  static ServerFailure getServerFailure(error) {
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              return getServerFailure("Request to API server was cancelled");

            case DioExceptionType.connectionTimeout:
              return getServerFailure("Connection timeout with API server");
            case DioExceptionType.unknown:
              return getServerFailure(
                  "Connection to API server failed due to internet connection");
            case DioExceptionType.receiveTimeout:
              return getServerFailure(
                  "Receive timeout in connection with API server");

            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 404:
                  return ServerFailure(
                      error.response!.data["message"] != null &&
                              error.response!.data["message"]
                                  .toString()
                                  .isNotEmpty
                          ? error.response!.data["message"].toString().trim()
                          : getTranslated("something_went_wrong"),
                      statusCode: 404);
                case 401:
                  // if (sl<LogoutBloc>().isLogin &&
                  //     sl<LogoutBloc>().state is! Loading) {
                  //   sl<LogoutBloc>().add(Click());
                  // }
                  return ServerFailure(
                      getTranslated("your_session_has_been_expired"),
                      statusCode: 401);
                case 500:
                  return ServerFailure(
                      error.response!.data["message"] != null &&
                              error.response!.data["message"]
                                  .toString()
                                  .isNotEmpty
                          ? error.response!.data["message"].toString().trim()
                          : getTranslated("something_went_wrong"),
                      statusCode: 500);
                case 503:
                  return ServerFailure(
                      error.response!.statusMessage ??
                          (error.response!.data["message"] != null &&
                                  error.response!.data["message"]
                                      .toString()
                                      .isNotEmpty
                              ? error.response!.data["message"]
                                  .toString()
                                  .trim()
                              : getTranslated("something_went_wrong")),
                      statusCode: 503);
                default:
                  try {
                    final message = error.response!.data["message"];
                    if (message != null && message.toString().isNotEmpty) {
                      return ServerFailure(message.toString(),
                          statusCode: error.response!.statusCode);
                    }
                    return ServerFailure(getTranslated("something_went_wrong"),
                        statusCode: error.response!.statusCode);
                  } catch (e) {
                    try {
                      final message = error.response!.data['data']["message"];
                      if (message != null && message.toString().isNotEmpty) {
                        return ServerFailure(message.toString(),
                            statusCode: error.response!.statusCode);
                      }
                    } catch (_) {}
                    return ServerFailure(getTranslated("something_went_wrong"),
                        statusCode: error.response!.statusCode);
                  }
              }
            case DioExceptionType.sendTimeout:
              return ServerFailure("Send timeout with server");
            case DioExceptionType.badCertificate:
              return ServerFailure("Bad Certificate with server");
            case DioExceptionType.connectionError:
              return ServerFailure("Connection Error with server");
          }
        } else {
          // ✅ Return the actual exception message instead of generic error
          return ServerFailure(error.toString());
        }
      } on FormatException catch (e) {
        // ✅ Return actual error instead of generic message
        return ServerFailure(e.toString());
      }
    } else {
      // ✅ Return the actual error instead of generic message
      return ServerFailure(error.toString());
    }
  }
}
