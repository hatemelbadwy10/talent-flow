import 'dart:io';

class EditWorkRequestModel {
  EditWorkRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.skillIds,
    this.previewLink,
    this.image,
    this.newFiles = const [],
    this.oldFiles = const [],
  });

  final int id;
  final String title;
  final String description;
  final String date;
  final List<int> skillIds;
  final String? previewLink;
  final File? image;
  final List<File> newFiles;
  final List<String> oldFiles;
}
