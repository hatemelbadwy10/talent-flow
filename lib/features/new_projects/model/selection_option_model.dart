import 'package:talent_flow/data/config/mapper.dart';

class SelectionModel extends SingleMapper {
  SelectionModel({
    required this.specializations,
    required this.jobTitles,
    required this.skills,
  });

  final Map<String, String> specializations;
  final Map<String, String> jobTitles;
  final Map<String, String> skills;

  factory SelectionModel.fromJson(Map<String, dynamic> json){
    return SelectionModel(
      specializations: Map.from(json["specializations"]).map((k, v) => MapEntry<String, String>(k, v)),
      jobTitles: Map.from(json["job_titles"]).map((k, v) => MapEntry<String, String>(k, v)),
      skills: Map.from(json["skills"]).map((k, v) => MapEntry<String, String>(k, v)),
    );
  }

  @override
  Mapper fromJson(Map<String, dynamic> json) {
return SelectionModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

}
