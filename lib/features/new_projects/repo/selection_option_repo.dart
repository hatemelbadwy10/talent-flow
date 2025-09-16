import 'package:dartz/dartz.dart';
import 'package:talent_flow/features/new_projects/model/selection_option_model.dart';

import '../../../data/api/end_points.dart';
import '../../../data/error/api_error_handler.dart';
import '../../../data/error/failures.dart';
import '../../../main_repos/base_repo.dart';

class SelectionOptionRepo extends BaseRepo{
  SelectionOptionRepo({required super.sharedPreferences, required super.dioClient});
Future<Either<Failure,SelectionModel>>getSelectionOption()async{
  try{
    final response=await dioClient.get(uri: EndPoints.selectionOption);
    return Right(SelectionModel.fromJson(response.data['payload']));
  }catch(error){
    return left(ApiErrorHandler.getServerFailure(error));
  }
}
}