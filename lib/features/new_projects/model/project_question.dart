class ProjectQuestion {
  const ProjectQuestion({
    required this.question,
    required this.isRequired,
  });

  final String question;
  final bool isRequired;

  Map<String, dynamic> toJson() => {
        'question': question,
        'required': isRequired ? 1 : 0,
      };

  factory ProjectQuestion.fromJson(Map<String, dynamic> json) {
    return ProjectQuestion(
      question: json['question']?.toString() ?? '',
      isRequired: json['required'] == 1 || json['required'] == true,
    );
  }
}
