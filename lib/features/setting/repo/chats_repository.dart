import 'package:dartz/dartz.dart';

import '../../../data/error/failures.dart';
import '../model/chats_model.dart';

abstract interface class ChatsRepository {
  Future<Either<ServerFailure, List<ChatsModel>>> getChats({
    int? projectId,
  });

  Future<Either<ServerFailure, Map<int, String>>> getProjectChatOptions();
}
