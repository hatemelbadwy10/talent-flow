import 'package:dartz/dartz.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';
import '../model/chats_model.dart';
import 'chats_repository.dart';

class ChatsRepo extends BaseRepo implements ChatsRepository {
  ChatsRepo({required super.sharedPreferences, required super.dioClient});

  @override
  Future<Either<ServerFailure, List<ChatsModel>>> getChats({
    int? projectId,
  }) async {
    try {
      final response = await dioClient.get(
        uri:
            '${EndPoints.conversations}?project_id=${projectId?.toString() ?? ''}',
      );
      final data = response.data;
      final payload = data is Map ? data['payload'] : null;
      if (payload is! List) {
        return left(ServerFailure('Invalid conversations response'));
      }
      final chats = payload
          .whereType<Map>()
          .map(
            (item) => ChatsModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList()
        ..sort(ChatsModel.compareNewestFirst);
      return right(chats);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }

  @override
  Future<Either<ServerFailure, Map<int, String>>>
      getProjectChatOptions() async {
    try {
      final response = await dioClient.get(uri: EndPoints.projectChatOptions);
      final data = response.data;
      final payload = data is Map ? data['payload'] : null;
      if (payload is! Map) {
        return left(ServerFailure('Invalid project options response'));
      }
      final options = <int, String>{};
      for (final entry in payload.entries) {
        final id = int.tryParse(entry.key.toString());
        if (id != null && entry.value is String) {
          options[id] = entry.value as String;
        }
      }
      return right(options);
    } catch (error) {
      return left(ApiErrorHandler.getServerFailure(error));
    }
  }
}
