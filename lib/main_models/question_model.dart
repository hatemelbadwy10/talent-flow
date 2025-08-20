import '../data/config/mapper.dart';

class QuestionModel extends SingleMapper {
  int? id;
  String? title;
  String? content;

  QuestionModel({
    this.id,
    this.title,
    this.content,
  });

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    content = json["content"];
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
      };

  @override
  Mapper fromJson(Map<String, dynamic> json) {
    return QuestionModel.fromJson(json);
  }
}
